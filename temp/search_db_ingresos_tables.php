<?php
// Buscar tablas en db_ingresos

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

    echo "TABLAS EN db_ingresos CON 'MERCADO', 'LOCAL', 'FECHA':\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'db_ingresos'
        AND (tablename LIKE '%mercado%'
          OR tablename LIKE '%local%'
          OR tablename LIKE '%fecha%'
          OR tablename LIKE '%sabado%'
          OR tablename LIKE '%desc%')
        ORDER BY tablename
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($tables as $table) {
        echo "db_ingresos.$table\n";
    }

    // Buscar SP sp_padron_global
    echo "\n\nSP sp_padron_global:\n";
    echo str_repeat('=', 100) . "\n";

    $stmt = $pdo->query("
        SELECT pg_get_functiondef(p.oid) as definition
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_padron_global'
        LIMIT 1
    ");

    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($result) {
        echo $result['definition'] . "\n";
    } else {
        echo "SP no encontrado\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
