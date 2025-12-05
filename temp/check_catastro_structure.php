<?php
// Check catastro table structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CATASTRO TABLE STRUCTURE ===\n\n";

    // Get table structure
    $stmt = $pdo->query("
        SELECT
            column_name,
            data_type,
            character_maximum_length,
            numeric_precision,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'catastro'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Columns found: " . count($columns) . "\n\n";

    foreach ($columns as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "(" . $col['character_maximum_length'] . ")";
        } elseif ($col['numeric_precision']) {
            $type .= "(" . $col['numeric_precision'] . ")";
        }
        echo "{$col['column_name']}: {$type} " . ($col['is_nullable'] === 'YES' ? 'NULL' : 'NOT NULL') . "\n";
    }

    echo "\n=== SAMPLE DATA (1 record) ===\n\n";

    // Get a sample record
    $stmt = $pdo->query("SELECT * FROM catastro_gdl.catastro LIMIT 1");
    $sample = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sample) {
        echo "Sample cvecat: " . ($sample['cvecat'] ?? 'N/A') . "\n\n";
        echo "Available fields in sample:\n";
        foreach (array_keys($sample) as $key) {
            echo "  - $key\n";
        }
    }

    echo "\n=== COUNT RECORDS ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.catastro");
    $count = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total records: {$count['total']}\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
