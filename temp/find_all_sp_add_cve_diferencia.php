<?php
// Buscar todos los SPs sp_add_cve_diferencia en todos los schemas

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

    // Buscar todos los SPs con ese nombre en todos los schemas
    $stmt = $pdo->query("
        SELECT
            n.nspname as schema,
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as argumentos,
            pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_add_cve_diferencia'
        ORDER BY n.nspname
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total de SPs encontrados: " . count($results) . "\n";
    echo str_repeat('=', 100) . "\n\n";

    foreach ($results as $i => $sp) {
        echo "SP #" . ($i + 1) . "\n";
        echo "Schema: {$sp['schema']}\n";
        echo "Nombre: {$sp['nombre']}\n";
        echo "Argumentos: {$sp['argumentos']}\n";
        echo str_repeat('-', 100) . "\n";
        echo $sp['definicion'] . "\n";
        echo str_repeat('=', 100) . "\n\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
