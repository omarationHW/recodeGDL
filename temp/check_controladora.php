<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Columns in catastro_gdl.controladora ===\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'controladora'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($columns as $col) {
        echo "- {$col['column_name']} ({$col['data_type']})\n";
    }

    echo "\n=== Sample data from controladora (first 3 rows) ===\n";
    $stmt = $pdo->query("SELECT * FROM catastro_gdl.controladora LIMIT 3");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total rows: " . count($rows) . "\n";
    foreach ($rows as $i => $row) {
        echo "\nRow " . ($i+1) . ":\n";
        foreach ($row as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "  $key: $value\n";
            }
        }
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
