<?php
/**
 * Script para verificar schemas disponibles en PostgreSQL
 */

$host = '192.168.6.146';
$port = '5432';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "Schemas disponibles en la base de datos '$database':\n\n";

    $stmt = $pdo->query("SELECT schema_name FROM information_schema.schemata ORDER BY schema_name");
    $schemas = $stmt->fetchAll(PDO::FETCH_COLUMN);

    foreach ($schemas as $schema) {
        echo "  - $schema\n";
    }

    echo "\n\nTablas en diferentes schemas:\n";

    $stmt = $pdo->query("
        SELECT table_schema, COUNT(*) as table_count
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema NOT IN ('pg_catalog', 'information_schema')
        GROUP BY table_schema
        ORDER BY table_schema
    ");

    $tableCounts = $stmt->fetchAll();

    foreach ($tableCounts as $row) {
        echo "  Schema '{$row['table_schema']}': {$row['table_count']} tablas\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
