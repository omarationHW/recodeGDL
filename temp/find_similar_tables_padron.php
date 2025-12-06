<?php
// Buscar tablas similares para locales y fecha_desc

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

    // Buscar tablas con 'local' en el nombre
    echo "TABLAS CON 'LOCAL':\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE '%local%'
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";
    }

    echo "\n\nTABLAS CON 'FECHA' o 'DESC':\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE '%fecha%desc%'
           OR tablename LIKE '%desc%fecha%'
           OR tablename LIKE '%sabado%'
        ORDER BY schemaname, tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tables as $table) {
        echo "{$table['schemaname']}.{$table['tablename']}\n";

        // Ver columnas de estas tablas
        $stmtCols = $pdo->prepare("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = :schema
            AND table_name = :table
            ORDER BY ordinal_position
        ");
        $stmtCols->execute([
            'schema' => $table['schemaname'],
            'table' => $table['tablename']
        ]);
        $cols = $stmtCols->fetchAll(PDO::FETCH_COLUMN);
        echo "  Columnas: " . implode(', ', $cols) . "\n\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
