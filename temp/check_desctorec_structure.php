<?php
// Check descuento recargos tables structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR DESCUENTO RECARGOS TABLES ===\n\n";

    // Search for tables with descuento and recargo
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%descrec%' OR table_name LIKE '%desc%rec%' OR table_name LIKE '%recarg%')
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl', 'multas_reglamentos', 'public')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($tables) . " tables:\n\n";

    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    // Check for general recargo tables
    echo "\n=== CHECKING RECARGOS TABLES ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%recarg%'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
        ORDER BY table_schema, table_name
    ");

    $recargo_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($recargo_tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    // Check if there's a specific table
    echo "\n=== CHECKING SPECIFIC TABLES ===\n\n";

    $tables_to_check = ['descrecargos', 'desc_recargos', 'descrec', 'desctorec'];

    foreach ($tables_to_check as $tname) {
        $stmt = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name = '{$tname}'
        ");

        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($results) > 0) {
            foreach ($results as $table) {
                echo "Found: {$table['table_schema']}.{$table['table_name']}\n";
            }
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
