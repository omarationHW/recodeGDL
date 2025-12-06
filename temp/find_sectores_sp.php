<?php
// Buscar SPs relacionados con sectores

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

    // Buscar SPs con 'sector' en el nombre
    echo "SPs CON 'SECTOR' EN EL NOMBRE:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as sp_name,
            pg_get_function_arguments(p.oid) as arguments
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname LIKE '%sector%'
        ORDER BY n.nspname, p.proname
    ");

    $sps = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($sps) > 0) {
        foreach ($sps as $sp) {
            echo "{$sp['schema']}.{$sp['sp_name']}\n";
            echo "  Argumentos: {$sp['arguments']}\n\n";
        }
    } else {
        echo "No se encontraron SPs con 'sector'\n\n";
    }

    // Buscar tabla de sectores
    echo "TABLAS CON 'SECTOR' EN EL NOMBRE:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE '%sector%'
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
        ");
        $stmtCols->execute([
            'schema' => $table['schemaname'],
            'table' => $table['tablename']
        ]);
        $cols = $stmtCols->fetchAll(PDO::FETCH_ASSOC);

        echo "  Columnas: ";
        echo implode(', ', array_column($cols, 'column_name'));
        echo "\n\n";
    }

    // Buscar todos los SPs disponibles
    echo "\nTODOS LOS SPs DISPONIBLES:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as sp_name
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
        AND p.proname LIKE 'sp_%'
        ORDER BY p.proname
    ");

    $allSps = $stmt->fetchAll(PDO::FETCH_COLUMN, 1);

    echo "Total de SPs: " . count($allSps) . "\n\n";

    // Mostrar los primeros 50
    foreach (array_slice($allSps, 0, 50) as $sp) {
        echo "  - $sp\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
