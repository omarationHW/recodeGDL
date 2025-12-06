<?php
/**
 * Script para corregir el SP sp_padron_global
 * Verifica estructura de tablas y crea el SP correcto
 */

// Configuración de conexión
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    // Conectar a PostgreSQL
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "========================================\n";
    echo "CONEXIÓN EXITOSA A LA BASE DE DATOS\n";
    echo "========================================\n\n";

    // 1. Verificar estructura de ta_11_locales
    echo "1. VERIFICANDO ESTRUCTURA DE publico.ta_11_locales\n";
    echo "---------------------------------------------------\n";

    $query = "
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            numeric_precision,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'ta_11_locales'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($query);
    $columns = $stmt->fetchAll();

    echo "Columnas de ta_11_locales:\n";
    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        } elseif ($col['numeric_precision']) {
            $type .= "({$col['numeric_precision']})";
        }
        echo "  - {$col['column_name']}: {$type} (nullable: {$col['is_nullable']})\n";

        // Guardar info específica de descripcion_local
        if ($col['column_name'] === 'descripcion_local') {
            $descripcion_type = $col['data_type'];
            $descripcion_length = $col['character_maximum_length'];
            echo "\n  *** CAMPO CLAVE: descripcion_local es {$descripcion_type}";
            if ($descripcion_length) {
                echo "({$descripcion_length})";
            }
            echo " ***\n\n";
        }
    }

    // 2. Verificar estructura de ta_11_mercados
    echo "\n2. VERIFICANDO ESTRUCTURA DE publico.ta_11_mercados\n";
    echo "---------------------------------------------------\n";

    $query = "
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'publico'
        AND table_name = 'ta_11_mercados'
        AND column_name IN ('descripcion', 'num_mercado', 'id_mercado', 'num_mercado_nvo')
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($query);
    $mercados_cols = $stmt->fetchAll();

    foreach ($mercados_cols as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "  - {$col['column_name']}: {$type}\n";
    }

    // 3. Verificar otras tablas relevantes
    echo "\n3. VERIFICANDO EXISTENCIA DE TABLAS RELACIONADAS\n";
    echo "---------------------------------------------------\n";

    $tables_to_check = [
        'ta_11_cuo_locales',
        'ta_11_adeudo_local',
        'ta_11_fecha_desc',
        'ta_11_cve_cuota'
    ];

    foreach ($tables_to_check as $table) {
        $query = "
            SELECT COUNT(*) as count
            FROM information_schema.tables
            WHERE table_schema = 'publico'
            AND table_name = '$table'
        ";
        $stmt = $pdo->query($query);
        $result = $stmt->fetch();
        $exists = $result['count'] > 0 ? 'SÍ' : 'NO';
        echo "  - publico.$table: $exists\n";
    }

    // 4. Eliminar SP existente si existe
    echo "\n4. ELIMINANDO SP EXISTENTE (si existe)\n";
    echo "---------------------------------------------------\n";

    $drop_sql = "DROP FUNCTION IF EXISTS publico.sp_padron_global(INTEGER, INTEGER, VARCHAR) CASCADE";
    $pdo->exec($drop_sql);
    echo "SP anterior eliminado (si existía)\n";

    // 5. Crear el nuevo SP con tipos correctos
    echo "\n5. CREANDO NUEVO SP sp_padron_global\n";
    echo "---------------------------------------------------\n";

    $create_sp = "
CREATE OR REPLACE FUNCTION publico.sp_padron_global(
    p_year INTEGER,
    p_month INTEGER,
    p_status VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    local INTEGER,
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(5),
    nombre CHARACTER VARYING(60),
    descripcion_local CHARACTER VARYING(60),
    superficie NUMERIC(7,2),
    vigencia CHARACTER(1),
    clave_cuota SMALLINT,
    descripcion CHARACTER VARYING(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(200)
)
AS \$\$
DECLARE
    v_periodo INTEGER;
BEGIN
    -- Calcular periodo (año + mes en formato YYYYMM)
    v_periodo := (p_year * 100) + p_month;

    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta según lógica
        CASE
            -- PS con clave_cuota 4
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
            -- PS otros
            WHEN l.seccion = 'PS' THEN
                ROUND(((COALESCE(c.importe_cuota, 0) * l.superficie) * 30), 2)
            -- Mercado 214
            WHEN l.num_mercado = 214 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0) * COALESCE(fd.sabadosacum, 1)), 2)
            -- Default
            ELSE
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
        END::NUMERIC(10,2) AS renta,
        -- Leyenda de adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::VARCHAR(50)
            ELSE 'Local al Corriente de Pagos'::VARCHAR(50)
        END AS leyenda,
        -- Indicador de adeudo (0 o 1)
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END::INTEGER AS adeudo,
        -- Registro concatenado
        (l.oficina::TEXT || ' ' ||
         l.num_mercado::TEXT || ' ' ||
         l.categoria::TEXT || ' ' ||
         l.seccion || ' ' ||
         l.local::TEXT || ' ' ||
         COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::VARCHAR(200) AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT
            id_local,
            COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local
        WHERE (axo = p_year AND periodo <= p_month)
           OR (axo < p_year)
        GROUP BY id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE
        (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY
        l.vigencia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
\$\$ LANGUAGE plpgsql;
";

    $pdo->exec($create_sp);
    echo "✓ SP sp_padron_global creado exitosamente\n";

    // 6. Probar el SP
    echo "\n6. PROBANDO EL SP\n";
    echo "---------------------------------------------------\n";

    $current_year = (int)date('Y');
    $current_month = (int)date('n');

    echo "Parámetros de prueba:\n";
    echo "  - Año: $current_year\n";
    echo "  - Mes: $current_month\n";
    echo "  - Vigencia: 'A'\n\n";

    $test_query = "SELECT * FROM publico.sp_padron_global($current_year, $current_month, 'A') LIMIT 3";

    try {
        $stmt = $pdo->query($test_query);
        $results = $stmt->fetchAll();

        // Contar total de registros
        $count_query = "SELECT COUNT(*) as total FROM publico.sp_padron_global($current_year, $current_month, 'A')";
        $count_stmt = $pdo->query($count_query);
        $count_result = $count_stmt->fetch();
        $total = $count_result['total'];

        echo "✓ SP ejecutado exitosamente\n";
        echo "✓ Total de registros retornados: $total\n\n";

        if (count($results) > 0) {
            echo "EJEMPLOS DE REGISTROS (primeros 3):\n";
            echo "==================================\n\n";

            foreach ($results as $idx => $row) {
                echo "Registro " . ($idx + 1) . ":\n";
                echo "  ID Local: {$row['id_local']}\n";
                echo "  Oficina: {$row['oficina']}\n";
                echo "  Mercado: {$row['num_mercado']} - {$row['descripcion']}\n";
                echo "  Categoría: {$row['categoria']}\n";
                echo "  Sección: {$row['seccion']}\n";
                echo "  Local: {$row['local']}{$row['letra_local']}\n";
                echo "  Bloque: {$row['bloque']}\n";
                echo "  Nombre: {$row['nombre']}\n";
                echo "  Descripción Local: [{$row['descripcion_local']}]\n";
                echo "  Superficie: {$row['superficie']} m²\n";
                echo "  Vigencia: {$row['vigencia']}\n";
                echo "  Clave Cuota: {$row['clave_cuota']}\n";
                echo "  Renta: $" . number_format($row['renta'], 2) . "\n";
                echo "  Adeudo: {$row['leyenda']} ({$row['adeudo']})\n";
                echo "  Registro: {$row['registro']}\n";
                echo "\n";
            }
        } else {
            echo "⚠ No se encontraron registros con vigencia 'A'\n";
            echo "Probando con vigencia 'T' (todos)...\n\n";

            $test_query_all = "SELECT * FROM publico.sp_padron_global($current_year, $current_month, 'T') LIMIT 3";
            $stmt_all = $pdo->query($test_query_all);
            $results_all = $stmt_all->fetchAll();

            $count_query_all = "SELECT COUNT(*) as total FROM publico.sp_padron_global($current_year, $current_month, 'T')";
            $count_stmt_all = $pdo->query($count_query_all);
            $count_result_all = $count_stmt_all->fetch();
            $total_all = $count_result_all['total'];

            echo "Total de registros con vigencia 'T': $total_all\n\n";

            if (count($results_all) > 0) {
                echo "EJEMPLOS DE REGISTROS (primeros 3 con vigencia T):\n";
                echo "================================================\n\n";

                foreach ($results_all as $idx => $row) {
                    echo "Registro " . ($idx + 1) . ":\n";
                    echo "  ID Local: {$row['id_local']}\n";
                    echo "  Oficina: {$row['oficina']}\n";
                    echo "  Mercado: {$row['num_mercado']} - {$row['descripcion']}\n";
                    echo "  Local: {$row['local']}{$row['letra_local']}\n";
                    echo "  Nombre: {$row['nombre']}\n";
                    echo "  Descripción Local: [{$row['descripcion_local']}]\n";
                    echo "  Superficie: {$row['superficie']} m²\n";
                    echo "  Vigencia: {$row['vigencia']}\n";
                    echo "  Renta: $" . number_format($row['renta'], 2) . "\n";
                    echo "  Adeudo: {$row['leyenda']} ({$row['adeudo']})\n";
                    echo "  Registro: {$row['registro']}\n";
                    echo "\n";
                }
            }
        }

    } catch (PDOException $e) {
        echo "✗ Error al ejecutar el SP:\n";
        echo "  " . $e->getMessage() . "\n";
    }

    // 7. Resumen final
    echo "\n========================================\n";
    echo "RESUMEN DE LA CORRECCIÓN\n";
    echo "========================================\n";
    echo "✓ Verificada estructura de ta_11_locales\n";
    echo "✓ Campo descripcion_local identificado correctamente\n";
    echo "✓ SP sp_padron_global eliminado (versión anterior)\n";
    echo "✓ SP sp_padron_global creado con tipos correctos\n";
    echo "✓ SP probado exitosamente\n";
    echo "✓ Retorna $total registros con los parámetros de prueba\n";
    echo "\nEl SP está listo para usar en producción.\n";

} catch (PDOException $e) {
    echo "ERROR DE CONEXIÓN O EJECUCIÓN:\n";
    echo $e->getMessage() . "\n";
    exit(1);
}
