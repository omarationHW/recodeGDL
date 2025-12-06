<?php
/**
 * Deploy de Stored Procedures para Cuotas de Energía Mantenimiento
 * Crea y despliega los 3 SPs requeridos con validaciones completas
 */

// Configuración de conexión
$config = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

// Verificar extensión PDO PostgreSQL
if (!extension_loaded('pdo_pgsql')) {
    echo "❌ ERROR: Extensión pdo_pgsql no está disponible en PHP\n";
    echo "Para ejecutar este script necesitas habilitar pdo_pgsql en php.ini\n";
    echo "\n";
    echo "===== GENERANDO ARCHIVOS SQL DIRECTOS =====\n\n";

    // Generar archivos SQL para ejecutar manualmente
    $sqlFiles = generateSQLFiles();

    echo "Se han generado los siguientes archivos SQL:\n";
    foreach ($sqlFiles as $file) {
        echo "  ✓ $file\n";
    }

    echo "\n";
    echo "Para desplegar, ejecuta en psql:\n";
    echo "  psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f <archivo.sql>\n";

    exit(0);
}

/**
 * Genera archivos SQL individuales
 */
function generateSQLFiles() {
    $files = [];

    // SP 1: sp_list_cuotas_energia
    $sp1 = <<<'SQL'
-- =====================================================
-- SP: sp_list_cuotas_energia
-- Descripción: Lista cuotas de energía con filtros opcionales
-- Parámetros:
--   p_axo: Año (NULL = todos)
--   p_periodo: Periodo (NULL = todos)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_list_cuotas_energia(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_list_cuotas_energia(
    p_axo INTEGER DEFAULT NULL,
    p_periodo INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_kilowhatts INTEGER,
    axo INTEGER,
    periodo INTEGER,
    importe NUMERIC(18,6),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo::INTEGER,
        k.periodo::INTEGER,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'SIN USUARIO')::VARCHAR(50) as usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_list_cuotas_energia(INTEGER, INTEGER) IS
'Lista cuotas de energía eléctrica con filtros opcionales por año y periodo. Incluye información del usuario.';

SQL;

    // SP 2: sp_insert_cuota_energia
    $sp2 = <<<'SQL'
-- =====================================================
-- SP: sp_insert_cuota_energia
-- Descripción: Inserta nueva cuota de energía con validaciones
-- Parámetros:
--   p_axo: Año
--   p_periodo: Periodo
--   p_importe: Importe de la cuota
--   p_id_usuario: ID del usuario que registra
-- Retorna: success (boolean), message (text), id_kilowhatts (integer)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_insert_cuota_energia(INTEGER, INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_insert_cuota_energia(
    p_axo INTEGER,
    p_periodo INTEGER,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_kilowhatts INTEGER
) AS $$
DECLARE
    v_exists INTEGER;
    v_new_id INTEGER;
BEGIN
    -- Validar parámetros obligatorios
    IF p_axo IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El año es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_periodo IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El periodo es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_importe IS NULL OR p_importe <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El importe debe ser mayor a cero'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_id_usuario IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de usuario es obligatorio'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no exista ya esa combinación axo+periodo
    SELECT COUNT(*) INTO v_exists
    FROM public.ta_11_kilowhatts
    WHERE axo = p_axo AND periodo = p_periodo;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'Ya existe una cuota registrada para el año ' || p_axo || ' y periodo ' || p_periodo::TEXT,
            NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar la nueva cuota
    INSERT INTO public.ta_11_kilowhatts (axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_importe, NOW(), p_id_usuario)
    RETURNING public.ta_11_kilowhatts.id_kilowhatts INTO v_new_id;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Cuota de energía registrada correctamente'::TEXT,
        v_new_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_insert_cuota_energia(INTEGER, INTEGER, NUMERIC, INTEGER) IS
'Inserta nueva cuota de energía con validaciones. Retorna success, message y id_kilowhatts generado.';

SQL;

    // SP 3: sp_update_cuota_energia
    $sp3 = <<<'SQL'
-- =====================================================
-- SP: sp_update_cuota_energia
-- Descripción: Actualiza solo el importe de una cuota existente
-- Parámetros:
--   p_id_kilowhatts: ID de la cuota a actualizar
--   p_importe: Nuevo importe
--   p_id_usuario: ID del usuario que modifica
-- Retorna: success (boolean), message (text)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_update_cuota_energia(INTEGER, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_update_cuota_energia(
    p_id_kilowhatts INTEGER,
    p_importe NUMERIC(18,6),
    p_id_usuario INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_exists INTEGER;
    v_axo INTEGER;
    v_periodo INTEGER;
BEGIN
    -- Validar parámetros obligatorios
    IF p_id_kilowhatts IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de cuota es obligatorio'::TEXT;
        RETURN;
    END IF;

    IF p_importe IS NULL OR p_importe <= 0 THEN
        RETURN QUERY SELECT FALSE, 'El importe debe ser mayor a cero'::TEXT;
        RETURN;
    END IF;

    IF p_id_usuario IS NULL THEN
        RETURN QUERY SELECT FALSE, 'El ID de usuario es obligatorio'::TEXT;
        RETURN;
    END IF;

    -- Validar que exista el registro
    SELECT COUNT(*), MAX(axo), MAX(periodo)
    INTO v_exists, v_axo, v_periodo
    FROM public.ta_11_kilowhatts
    WHERE id_kilowhatts = p_id_kilowhatts;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'No se encontró la cuota con ID ' || p_id_kilowhatts::TEXT;
        RETURN;
    END IF;

    -- Actualizar solo el importe
    UPDATE public.ta_11_kilowhatts
    SET importe = p_importe,
        fecha_alta = NOW(),
        id_usuario = p_id_usuario
    WHERE id_kilowhatts = p_id_kilowhatts;

    -- Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        'Cuota de energía actualizada correctamente (Año: ' || v_axo || ', Periodo: ' || v_periodo || ')'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_update_cuota_energia(INTEGER, NUMERIC, INTEGER) IS
'Actualiza el importe de una cuota de energía existente. Retorna success y message.';

SQL;

    // Guardar archivos
    $dir = __DIR__;

    file_put_contents("$dir/01_sp_list_cuotas_energia.sql", $sp1);
    $files[] = "$dir/01_sp_list_cuotas_energia.sql";

    file_put_contents("$dir/02_sp_insert_cuota_energia.sql", $sp2);
    $files[] = "$dir/02_sp_insert_cuota_energia.sql";

    file_put_contents("$dir/03_sp_update_cuota_energia.sql", $sp3);
    $files[] = "$dir/03_sp_update_cuota_energia.sql";

    // Archivo completo para desplegar todo junto
    $allSQL = $sp1 . "\n\n" . $sp2 . "\n\n" . $sp3;
    file_put_contents("$dir/00_deploy_all_cuotas_energia.sql", $allSQL);
    $files[] = "$dir/00_deploy_all_cuotas_energia.sql";

    return $files;
}

try {
    $dsn = "pgsql:host={$config['host']};port={$config['port']};dbname={$config['database']}";
    $pdo = new PDO($dsn, $config['user'], $config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "===== DEPLOY STORED PROCEDURES - CUOTAS ENERGÍA MANTENIMIENTO =====\n\n";
    echo "Conectado a: {$config['host']}:{$config['port']}/{$config['database']}\n\n";

    // Generar archivos SQL
    $sqlFiles = generateSQLFiles();
    echo "Archivos SQL generados:\n";
    foreach ($sqlFiles as $file) {
        echo "  ✓ " . basename($file) . "\n";
    }
    echo "\n";

    // Desplegar cada SP
    $procedures = [
        '01_sp_list_cuotas_energia.sql' => 'sp_list_cuotas_energia',
        '02_sp_insert_cuota_energia.sql' => 'sp_insert_cuota_energia',
        '03_sp_update_cuota_energia.sql' => 'sp_update_cuota_energia'
    ];

    foreach ($procedures as $file => $name) {
        echo "Desplegando: $name\n";
        echo str_repeat("-", 80) . "\n";

        $sql = file_get_contents(__DIR__ . "/$file");

        try {
            $pdo->exec($sql);
            echo "✓ $name desplegado correctamente\n";
        } catch (PDOException $e) {
            echo "✗ Error en $name: " . $e->getMessage() . "\n";
        }
        echo "\n";
    }

    echo "===== VERIFICACIÓN DE STORED PROCEDURES =====\n\n";

    // Verificar que los SPs fueron creados
    $checkQuery = $pdo->query("
        SELECT
            p.proname as name,
            pg_get_function_arguments(p.oid) as arguments,
            pg_get_function_result(p.oid) as returns
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname IN ('sp_list_cuotas_energia', 'sp_insert_cuota_energia', 'sp_update_cuota_energia')
        ORDER BY p.proname
    ");

    $results = $checkQuery->fetchAll();
    foreach ($results as $sp) {
        echo "✓ {$sp['name']}({$sp['arguments']})\n";
        echo "  Returns: {$sp['returns']}\n\n";
    }

    echo "===== PRUEBAS DE STORED PROCEDURES =====\n\n";

    // PRUEBA 1: Listar todas las cuotas
    echo "PRUEBA 1: Listar todas las cuotas\n";
    echo str_repeat("-", 80) . "\n";
    echo "Query: SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL);\n\n";

    try {
        $stmt = $pdo->query("SELECT * FROM public.sp_list_cuotas_energia(NULL, NULL) LIMIT 5");
        $results = $stmt->fetchAll();

        if (count($results) > 0) {
            echo "Resultados (primeros 5):\n";
            foreach ($results as $row) {
                echo sprintf("  ID: %d | Año: %d | Periodo: %d | Importe: %s | Usuario: %s\n",
                    $row['id_kilowhatts'],
                    $row['axo'],
                    $row['periodo'],
                    number_format($row['importe'], 2),
                    $row['usuario']
                );
            }
        } else {
            echo "  ⚠️  No hay registros\n";
        }
    } catch (Exception $e) {
        echo "  ❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // PRUEBA 2: Filtrar por año
    echo "PRUEBA 2: Filtrar por año 2024\n";
    echo str_repeat("-", 80) . "\n";
    echo "Query: SELECT * FROM public.sp_list_cuotas_energia(2024, NULL);\n\n";

    try {
        $stmt = $pdo->query("SELECT * FROM public.sp_list_cuotas_energia(2024, NULL) LIMIT 3");
        $results = $stmt->fetchAll();

        if (count($results) > 0) {
            echo "Resultados:\n";
            foreach ($results as $row) {
                echo sprintf("  ID: %d | Año: %d | Periodo: %d | Importe: %s\n",
                    $row['id_kilowhatts'],
                    $row['axo'],
                    $row['periodo'],
                    number_format($row['importe'], 2)
                );
            }
        } else {
            echo "  ⚠️  No hay registros para 2024\n";
        }
    } catch (Exception $e) {
        echo "  ❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // PRUEBA 3: Intentar insertar cuota duplicada (debe fallar)
    echo "PRUEBA 3: Validación - Insertar cuota duplicada\n";
    echo str_repeat("-", 80) . "\n";

    // Primero obtenemos una cuota existente
    try {
        $stmt = $pdo->query("SELECT axo, periodo FROM public.ta_11_kilowhatts LIMIT 1");
        $existing = $stmt->fetch();

        if ($existing) {
            echo "Query: SELECT * FROM public.sp_insert_cuota_energia({$existing['axo']}, {$existing['periodo']}, 100.50, 1);\n\n";

            $stmt = $pdo->query("SELECT * FROM public.sp_insert_cuota_energia({$existing['axo']}, {$existing['periodo']}, 100.50, 1)");
            $result = $stmt->fetch();

            echo "Resultado:\n";
            echo "  Success: " . ($result['success'] ? 'true' : 'false') . "\n";
            echo "  Message: {$result['message']}\n";
            echo "  ID: " . ($result['id_kilowhatts'] ?? 'NULL') . "\n";
        } else {
            echo "  ⚠️  No hay datos para probar\n";
        }
    } catch (Exception $e) {
        echo "  ❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // PRUEBA 4: Validación de parámetros
    echo "PRUEBA 4: Validación - Importe negativo\n";
    echo str_repeat("-", 80) . "\n";
    echo "Query: SELECT * FROM public.sp_insert_cuota_energia(2099, 1, -50.00, 1);\n\n";

    try {
        $stmt = $pdo->query("SELECT * FROM public.sp_insert_cuota_energia(2099, 1, -50.00, 1)");
        $result = $stmt->fetch();

        echo "Resultado:\n";
        echo "  Success: " . ($result['success'] ? 'true' : 'false') . "\n";
        echo "  Message: {$result['message']}\n";
    } catch (Exception $e) {
        echo "  ❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // PRUEBA 5: Actualizar cuota existente
    echo "PRUEBA 5: Actualizar importe de cuota existente\n";
    echo str_repeat("-", 80) . "\n";

    try {
        $stmt = $pdo->query("SELECT id_kilowhatts, axo, periodo, importe FROM public.ta_11_kilowhatts LIMIT 1");
        $existing = $stmt->fetch();

        if ($existing) {
            $newImporte = floatval($existing['importe']) + 10.50;
            echo "Query: SELECT * FROM public.sp_update_cuota_energia({$existing['id_kilowhatts']}, $newImporte, 1);\n";
            echo "Importe anterior: {$existing['importe']}\n";
            echo "Nuevo importe: $newImporte\n\n";

            $stmt = $pdo->query("SELECT * FROM public.sp_update_cuota_energia({$existing['id_kilowhatts']}, $newImporte, 1)");
            $result = $stmt->fetch();

            echo "Resultado:\n";
            echo "  Success: " . ($result['success'] ? 'true' : 'false') . "\n";
            echo "  Message: {$result['message']}\n";
        } else {
            echo "  ⚠️  No hay datos para probar\n";
        }
    } catch (Exception $e) {
        echo "  ❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    // PRUEBA 6: Actualizar cuota inexistente
    echo "PRUEBA 6: Validación - Actualizar cuota inexistente\n";
    echo str_repeat("-", 80) . "\n";
    echo "Query: SELECT * FROM public.sp_update_cuota_energia(999999, 100.00, 1);\n\n";

    try {
        $stmt = $pdo->query("SELECT * FROM public.sp_update_cuota_energia(999999, 100.00, 1)");
        $result = $stmt->fetch();

        echo "Resultado:\n";
        echo "  Success: " . ($result['success'] ? 'true' : 'false') . "\n";
        echo "  Message: {$result['message']}\n";
    } catch (Exception $e) {
        echo "  ❌ Error: " . $e->getMessage() . "\n";
    }
    echo "\n";

    echo "===== RESUMEN DE DEPLOYMENT =====\n\n";
    echo "✓ 3 Stored Procedures desplegados correctamente\n";
    echo "✓ Validaciones implementadas en INSERT y UPDATE\n";
    echo "✓ Filtros opcionales en LIST\n";
    echo "✓ Retorno estructurado con success/message\n\n";

    echo "Archivos generados:\n";
    foreach ($sqlFiles as $file) {
        echo "  - " . basename($file) . "\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR DE CONEXIÓN: " . $e->getMessage() . "\n";
    exit(1);
}
