<?php
// Check fosa/panteones tables structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR FOSA/PANTEONES TABLES ===\n\n";

    // Search for tables with fosa or panteon
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%fosa%' OR table_name LIKE '%panteon%')
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl', 'multas_reglamentos', 'public')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($tables) . " tables:\n\n";

    foreach ($tables as $table) {
        // Get count
        try {
            $count_stmt = $pdo->query("SELECT COUNT(*) as count FROM {$table['table_schema']}.{$table['table_name']}");
            $count = $count_stmt->fetch(PDO::FETCH_ASSOC)['count'];
            echo "{$table['table_schema']}.{$table['table_name']} ({$count} records)\n";
        } catch (Exception $e) {
            echo "{$table['table_schema']}.{$table['table_name']} (error reading)\n";
        }
    }

    // Check for derechos tables
    echo "\n=== CHECKING DERECHOS TABLES ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%derech%'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    $derechos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($derechos as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
