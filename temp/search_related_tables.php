<?php
// Buscar tablas relacionadas con multas, pagos, propuestas
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS RELACIONADAS ===\n\n";

    $keywords = ['multa', 'pago', 'recaudadora', 'propuesta', 'tabla', 'tab'];

    foreach ($keywords as $keyword) {
        echo "--- Buscando '$keyword' ---\n\n";

        $sql = "
            SELECT
                schemaname,
                tablename
            FROM pg_tables
            WHERE tablename ILIKE '%$keyword%'
            AND schemaname IN ('comun', 'comunX', 'db_ingresos', 'public', 'multas_reglamentos', 'padron_licencias')
            ORDER BY schemaname, tablename
            LIMIT 10
        ";

        $stmt = $pdo->query($sql);
        $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (!empty($tables)) {
            foreach ($tables as $table) {
                echo "  {$table['schemaname']}.{$table['tablename']}\n";
            }
        } else {
            echo "  (ninguna encontrada)\n";
        }
        echo "\n";
    }

    // Buscar en el schema comun específicamente
    echo "\n=== TABLAS EN SCHEMA 'comun' CON 'TAB' ===\n\n";

    $sql = "
        SELECT
            tablename,
            pg_size_pretty(pg_total_relation_size('comun.'||tablename)) as size
        FROM pg_tables
        WHERE schemaname = 'comun'
        AND (tablename ILIKE '%tab%' OR tablename ILIKE '%propues%')
        ORDER BY tablename
        LIMIT 20
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        try {
            $countSql = "SELECT COUNT(*) as total FROM comun.{$table['tablename']}";
            $countStmt = $pdo->query($countSql);
            $count = $countStmt->fetch(PDO::FETCH_ASSOC);
            echo "{$table['tablename']} - Registros: {$count['total']} - Tamaño: {$table['size']}\n";
        } catch (Exception $e) {
            echo "{$table['tablename']} - Error al contar\n";
        }
    }

    // Buscar SPs existentes con propuesta
    echo "\n\n=== STORED PROCEDURES CON 'PROPUESTA' ===\n\n";

    $spSql = "
        SELECT
            n.nspname as schema,
            p.proname as procedure_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname ILIKE '%propuesta%'
        AND n.nspname NOT IN ('pg_catalog', 'information_schema')
        ORDER BY n.nspname, p.proname
    ";

    $spStmt = $pdo->query($spSql);
    $sps = $spStmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($sps)) {
        foreach ($sps as $sp) {
            echo "{$sp['schema']}.{$sp['procedure_name']}({$sp['arguments']})\n";
        }
    } else {
        echo "No se encontraron SPs con 'propuesta'\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
