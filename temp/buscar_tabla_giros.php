<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BUSCANDO TABLAS CON 'GIRO' ===\n\n";

    $query = "
    SELECT table_schema, table_name
    FROM information_schema.tables
    WHERE table_name LIKE '%giro%'
    ORDER BY table_schema, table_name
    ";

    $stmt = $pdo->query($query);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tables) > 0) {
        foreach ($tables as $table) {
            echo "{$table['table_schema']}.{$table['table_name']}\n";
        }
    } else {
        echo "No se encontraron tablas con 'giro'\n";
    }

    echo "\n=== BUSCANDO TABLAS EN SCHEMA COMUN ===\n\n";

    $query2 = "
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'comun'
    ORDER BY table_name
    ";

    $stmt2 = $pdo->query($query2);
    $tables2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables2 as $table) {
        echo "comun.{$table['table_name']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
