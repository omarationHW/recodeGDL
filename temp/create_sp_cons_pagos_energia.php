<?php
/**
 * Script para crear el SP sp_cons_pagos_energia
 * Busca pagos de energía por id_energia
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n=== CREANDO SP PARA PAGOS DE ENERGÍA ===\n\n";

    // 1. Verificar estructura de la tabla de pagos
    echo "1. Verificando tabla de pagos de energía...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            table_schema,
            table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%pago%energia%'
           OR table_name LIKE '%energia%pago%'
        ORDER BY table_schema, table_name
    ";

    $stmt = $pdo->query($sql);
    $tablas = $stmt->fetchAll();

    if (count($tablas) > 0) {
        echo "Tablas encontradas:\n";
        foreach ($tablas as $t) {
            echo "  - {$t['table_schema']}.{$t['table_name']}\n";
        }
    } else {
        echo "❌ No se encontraron tablas de pagos de energía\n";
        exit(1);
    }

    // Usar la primera tabla encontrada
    $tabla_pagos = $tablas[0];
    echo "\nUsando tabla: {$tabla_pagos['table_schema']}.{$tabla_pagos['table_name']}\n\n";

    // 2. Ver estructura de la tabla
    echo "2. Estructura de la tabla:\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            column_name,
            data_type
        FROM information_schema.columns
        WHERE table_schema = '{$tabla_pagos['table_schema']}'
          AND table_name = '{$tabla_pagos['table_name']}'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sql);
    $columnas = $stmt->fetchAll();

    foreach ($columnas as $col) {
        echo "  - {$col['column_name']}: {$col['data_type']}\n";
    }

    // 3. Verificar si existe el campo id_energia
    $tiene_id_energia = false;
    foreach ($columnas as $col) {
        if ($col['column_name'] === 'id_energia') {
            $tiene_id_energia = true;
            break;
        }
    }

    if (!$tiene_id_energia) {
        echo "\n❌ La tabla no tiene el campo 'id_energia'\n";
        exit(1);
    }

    echo "\n✅ Tabla válida con campo id_energia\n\n";

    // 4. Crear el SP
    echo "3. Creando stored procedure sp_cons_pagos_energia...\n";
    echo str_repeat("-", 80) . "\n";

    $schema = $tabla_pagos['table_schema'];
    $tabla = $tabla_pagos['table_name'];

    $sql_sp = "
    DROP FUNCTION IF EXISTS sp_cons_pagos_energia(INTEGER);

    CREATE OR REPLACE FUNCTION sp_cons_pagos_energia(
        p_id_energia INTEGER
    ) RETURNS TABLE(
        id_pago_energia INTEGER,
        id_energia INTEGER,
        axo SMALLINT,
        periodo SMALLINT,
        fecha_pago DATE,
        oficina_pago SMALLINT,
        caja_pago CHAR(2),
        operacion_pago INTEGER,
        importe_pago NUMERIC(10,2),
        folio VARCHAR(30),
        fecha_modificacion TIMESTAMP,
        id_usuario INTEGER
    ) AS \$\$
    BEGIN
        RETURN QUERY
        SELECT
            p.id_pago_energia,
            p.id_energia,
            p.axo::SMALLINT,
            p.periodo::SMALLINT,
            p.fecha_pago::DATE,
            p.oficina_pago::SMALLINT,
            p.caja_pago::CHAR(2),
            p.operacion_pago::INTEGER,
            COALESCE(p.importe_pago, 0)::NUMERIC(10,2) as importe_pago,
            COALESCE(TRIM(p.folio), '')::VARCHAR(30) as folio,
            p.fecha_modificacion::TIMESTAMP,
            p.id_usuario::INTEGER
        FROM {$schema}.{$tabla} p
        WHERE p.id_energia = p_id_energia
        ORDER BY p.axo DESC, p.periodo DESC, p.fecha_pago DESC
        LIMIT 500;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql_sp);
    echo "✅ SP creado exitosamente\n\n";

    // 5. Verificar creación
    echo "4. Verificando SP creado...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "
        SELECT
            proname as nombre_sp,
            pg_get_function_arguments(oid) as argumentos
        FROM pg_proc
        WHERE proname = 'sp_cons_pagos_energia'
    ";

    $stmt = $pdo->query($sql);
    $sp = $stmt->fetch();

    if ($sp) {
        echo "✅ {$sp['nombre_sp']}({$sp['argumentos']})\n";
    } else {
        echo "❌ SP no encontrado después de creación\n";
        exit(1);
    }

    // 6. Buscar un id_energia de prueba
    echo "\n5. Buscando ID de energía de prueba...\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "SELECT DISTINCT id_energia FROM {$schema}.{$tabla} WHERE id_energia IS NOT NULL LIMIT 5";
    $stmt = $pdo->query($sql);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (count($ids) > 0) {
        echo "IDs de energía disponibles para pruebas:\n";
        foreach ($ids as $id) {
            echo "  - $id\n";
        }

        // Probar con el primer ID
        $test_id = $ids[0];
        echo "\n6. Probando SP con id_energia = $test_id...\n";
        echo str_repeat("-", 80) . "\n";

        $stmt = $pdo->query("SELECT * FROM sp_cons_pagos_energia($test_id) LIMIT 3");
        $resultados = $stmt->fetchAll();

        if (count($resultados) > 0) {
            echo "✅ SP funciona correctamente. Retornó " . count($resultados) . " registros:\n";
            foreach ($resultados as $r) {
                echo "  - Año: {$r['axo']}, Periodo: {$r['periodo']}, Importe: \${$r['importe_pago']}\n";
            }
        } else {
            echo "⚠️  SP no retornó datos para este ID (puede ser normal)\n";
        }
    } else {
        echo "⚠️  No hay datos en la tabla para probar\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "✅ PROCESO COMPLETADO EXITOSAMENTE\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
