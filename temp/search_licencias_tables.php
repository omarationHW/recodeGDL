<?php
// Search for licencias tables

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR LICENCIAS TABLES ===\n\n";

    // Search for main licencias tables
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%licenc%' OR table_name LIKE '%lic%')
        AND table_name NOT LIKE '%public%'
        AND table_name NOT LIKE '%olic%'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl', 'padron_licencias')
        ORDER BY
            CASE
                WHEN table_name = 'licencias' THEN 1
                WHEN table_name LIKE 'h_licencias%' THEN 2
                WHEN table_name LIKE 'licen%' THEN 3
                ELSE 4
            END,
            table_schema, table_name
        LIMIT 20
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($tables) . " main tables:\n\n";

    foreach ($tables as $t) {
        echo "{$t['table_schema']}.{$t['table_name']}\n";
    }

    // Check for h_licencias table specifically
    echo "\n=== CHECKING h_licencias TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'h_licencias'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl', 'padron_licencias')
    ");

    $hlicencias = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($hlicencias) > 0) {
        foreach ($hlicencias as $t) {
            echo "Found: {$t['table_schema']}.{$t['table_name']}\n";

            // Get columns
            $stmt2 = $pdo->query("
                SELECT column_name, data_type
                FROM information_schema.columns
                WHERE table_schema = '{$t['table_schema']}'
                AND table_name = '{$t['table_name']}'
                ORDER BY ordinal_position
                LIMIT 20
            ");

            $columns = $stmt2->fetchAll(PDO::FETCH_ASSOC);
            echo "\nFirst 20 columns:\n";
            foreach ($columns as $col) {
                echo "  - {$col['column_name']} ({$col['data_type']})\n";
            }

            // Get sample data
            echo "\n=== SAMPLE DATA ===\n\n";
            $stmt3 = $pdo->query("SELECT * FROM {$t['table_schema']}.{$t['table_name']} LIMIT 5");
            $samples = $stmt3->fetchAll(PDO::FETCH_ASSOC);

            foreach ($samples as $i => $row) {
                echo "Sample " . ($i + 1) . ":\n";
                $count = 0;
                foreach ($row as $key => $value) {
                    if ($count < 10) {  // Show first 10 columns only
                        echo "  {$key}: " . ($value ?? 'NULL') . "\n";
                        $count++;
                    }
                }
                echo "\n";
            }

            // Get total count
            $stmt4 = $pdo->query("SELECT COUNT(*) as total FROM {$t['table_schema']}.{$t['table_name']}");
            $total = $stmt4->fetch(PDO::FETCH_ASSOC);
            echo "Total records: {$total['total']}\n\n";
        }
    } else {
        echo "h_licencias table not found\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
