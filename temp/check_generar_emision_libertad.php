<?php
// Conexión directa a PostgreSQL
$host = 'localhost';
$port = '5432';
$dbname = 'postgres';
$user = 'postgres';
$password = 'sistemas';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "========================================\n";
    echo "VERIFICACIÓN SP: generar_emision_libertad\n";
    echo "========================================\n\n";

    // 1. Verificar si existe el SP
    echo "1. Buscando SP generar_emision_libertad en todos los schemas:\n";
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema_name,
            p.proname as sp_name,
            pg_get_function_identity_arguments(p.oid) as parameters
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%generar_emision_libertad%'
        ORDER BY n.nspname, p.proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "   ✓ Encontrado: {$sp['schema_name']}.{$sp['sp_name']}({$sp['parameters']})\n";
        }
    } else {
        echo "   ✗ NO ENCONTRADO en ningún schema\n";
    }
    echo "\n";

    // 2. Buscar tablas usadas por el SP
    echo "2. Buscando tablas necesarias:\n";
    $tables = [
        'ta_11_locales',
        'ta_11_mercados',
        'ta_11_cuo_locales',
        'ta_11_adeudo_local',
        'ta_15_apremios',
        'ta_12_recaudadoras'
    ];

    $found_tables = [];
    foreach ($tables as $table) {
        $stmt = $pdo->prepare("
            SELECT
                schemaname as schema_name,
                tablename as table_name,
                (SELECT count(*) FROM information_schema.columns
                 WHERE table_schema = schemaname AND table_name = tablename) as column_count
            FROM pg_tables
            WHERE tablename = :table
            AND schemaname NOT IN ('pg_catalog', 'information_schema')
            ORDER BY schemaname
        ");
        $stmt->execute(['table' => $table]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            foreach ($results as $row) {
                echo "   ✓ {$table}: {$row['schema_name']} ({$row['column_count']} columnas)\n";
                $found_tables[$table] = $row['schema_name'];
            }
        } else {
            echo "   ✗ {$table}: NO ENCONTRADA\n";
        }
    }
    echo "\n";

    // 3. Verificar otros SPs de EmisionLibertad
    echo "3. Verificando otros SPs de EmisionLibertad:\n";
    $other_sps = [
        'get_recaudadoras',
        'get_mercados_by_recaudadora',
        'exportar_emision_libertad',
        'get_emision_libertad_detalle'
    ];

    foreach ($other_sps as $sp_name) {
        $stmt = $pdo->prepare("
            SELECT n.nspname as schema_name, p.proname as sp_name
            FROM pg_proc p
            JOIN pg_namespace n ON p.pronamespace = n.oid
            WHERE p.proname = :sp_name
            ORDER BY n.nspname
        ");
        $stmt->execute(['sp_name' => $sp_name]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            foreach ($results as $row) {
                echo "   ✓ {$sp_name}: {$row['schema_name']}\n";
            }
        } else {
            echo "   ✗ {$sp_name}: NO ENCONTRADO\n";
        }
    }
    echo "\n";

    // 4. Verificar datos de prueba en ta_12_recaudadoras
    if (isset($found_tables['ta_12_recaudadoras'])) {
        $schema = $found_tables['ta_12_recaudadoras'];
        echo "4. Datos de prueba en {$schema}.ta_12_recaudadoras:\n";
        $stmt = $pdo->query("
            SELECT id_rec, recaudadora
            FROM {$schema}.ta_12_recaudadoras
            WHERE id_rec >= 1
            ORDER BY id_rec
            LIMIT 5
        ");
        $recaudadoras = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($recaudadoras) > 0) {
            foreach ($recaudadoras as $rec) {
                echo "   - ID: {$rec['id_rec']}, Recaudadora: {$rec['recaudadora']}\n";
            }
        } else {
            echo "   No hay datos\n";
        }
    }

    echo "\n========================================\n";
    echo "RESUMEN:\n";
    echo "========================================\n";
    if (count($sps) === 0) {
        echo "❌ El SP generar_emision_libertad NO EXISTE en la base de datos\n";
        echo "   Necesita ser desplegado desde:\n";
        echo "   RefactorX/Base/mercados/database/ok/47_SP_MERCADOS_EMISIONLIBERTAD_EXACTO_all_procedures.sql\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
