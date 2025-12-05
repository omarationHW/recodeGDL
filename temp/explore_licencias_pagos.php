<?php
// Script para explorar tablas de licencias y pagos

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== BÚSQUEDA DE TABLAS DE LICENCIAS ===\n\n";

    // Buscar tablas relacionadas con licencias en diferentes schemas
    $schemas = ['padron_licencias', 'db_ingresos', 'comun', 'public'];

    foreach ($schemas as $schema) {
        echo "--- Schema: $schema ---\n";
        $stmt = $pdo->query("
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '$schema'
            AND table_name LIKE '%lic%'
            ORDER BY table_name
            LIMIT 20
        ");

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "  - {$row['table_name']}\n";
        }
        echo "\n";
    }

    // Buscar específicamente tablas de detalle de licencias
    echo "=== TABLAS DETSAL_LIC ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name IN ('detsal_lic', 'detsallic', 'detalle_licencias')
        ORDER BY table_schema
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  - {$row['table_schema']}.{$row['table_name']}\n";
    }

    // Intentar obtener estructura de detsal_lic si existe
    echo "\n=== ESTRUCTURA DE DETSAL_LIC ===\n";
    try {
        $stmt = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_name = 'detsal_lic'
            AND table_schema IN ('padron_licencias', 'db_ingresos', 'comun')
            ORDER BY ordinal_position
            LIMIT 30
        ");

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "  {$row['column_name']} ({$row['data_type']})\n";
        }
    } catch (Exception $e) {
        echo "  No se encontró la tabla detsal_lic\n";
    }

    // Buscar tablas de licencias generales
    echo "\n=== TABLAS LICENCIAS ===\n";
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name IN ('licencias', 'licencia', 'lic')
        ORDER BY table_schema
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  - {$row['table_schema']}.{$row['table_name']}\n";
    }

    // Buscar datos de ejemplo en padron_licencias
    echo "\n=== EJEMPLO DE DATOS EN PADRON_LICENCIAS ===\n";
    try {
        $stmt = $pdo->query("
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'padron_licencias'
            LIMIT 10
        ");

        echo "Tablas en padron_licencias:\n";
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            echo "  - {$row['table_name']}\n";
        }
    } catch (Exception $e) {
        echo "  Error: " . $e->getMessage() . "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
