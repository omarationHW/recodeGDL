<?php
// Buscar SPs y tablas relacionados con movimientos

$dbConfig = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

try {
    $dsn = "pgsql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['dbname']}";
    $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos\n\n";

    // Buscar SPs con 'movimiento' en el nombre
    echo "SPs CON 'MOVIMIENTO' EN EL NOMBRE:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%movim%'
        ORDER BY n.nspname, p.proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "{$sp['schema']}.{$sp['sp_name']}\n";
            echo "  Argumentos: {$sp['arguments']}\n\n";
        }
    } else {
        echo "No se encontraron SPs con 'movimiento'\n\n";
    }

    // Buscar tablas con 'movimiento' en el nombre
    echo "TABLAS CON 'MOVIMIENTO' EN EL NOMBRE:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE '%movim%'
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";

        // Ver estructura
        $stmtCols = $pdo->prepare("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = :schema
            AND table_name = :table
            ORDER BY ordinal_position
            LIMIT 10
        ");
        $stmtCols->execute([
            'schema' => $table['schemaname'],
            'table' => $table['tablename']
        ]);
        $cols = $stmtCols->fetchAll(PDO::FETCH_ASSOC);

        echo "  Columnas: ";
        echo implode(', ', array_column($cols, 'column_name'));
        echo "\n";

        // Ver datos de ejemplo
        $stmtData = $pdo->query("
            SELECT * FROM {$table['schemaname']}.{$table['tablename']}
            LIMIT 5
        ");
        $data = $stmtData->fetchAll(PDO::FETCH_ASSOC);

        if (count($data) > 0) {
            echo "  Registros: " . count($data) . "\n";
            foreach ($data as $i => $row) {
                echo "    " . ($i + 1) . ". " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
            }
        }
        echo "\n";
    }

    // Buscar tablas con 'tipo_movimiento' como columna
    echo "TABLAS CON COLUMNA 'tipo_movimiento':\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name LIKE '%movimiento%'
        AND table_schema = 'public'
        GROUP BY table_schema, table_name
    ");

    $tablesWithCol = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tablesWithCol as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
