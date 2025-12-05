<?php
// Check descuentos prediales tables structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR DESCUENTOS PREDIALES TABLES ===\n\n";

    // Search for tables with descpred or descuento predial
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%descpred%' OR table_name LIKE '%desc%pred%')
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl', 'multas_reglamentos', 'public')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($tables) . " tables:\n\n";

    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    // Also search for general descuento tables
    echo "\n=== CHECKING DESCUENTO TABLES ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%descuento%'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
        ORDER BY table_schema, table_name
    ");

    $desc_tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($desc_tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    // Check for predios/catastro tables
    echo "\n=== CHECKING PREDIOS/CATASTRO TABLES ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%predio%' OR table_name LIKE '%catastro%')
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    $predios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($predios as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
