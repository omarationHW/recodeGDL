<?php
// Search for otras obligaciones tables

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR OTRAS OBLIGACIONES TABLES ===\n\n";

    // Search for tables
    $keywords = ['oblig', 'otras', 'h_otras', 'otras_obligaciones'];

    foreach ($keywords as $keyword) {
        echo "Searching for '$keyword':\n";
        $stmt = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name LIKE '%{$keyword}%'
            AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
            ORDER BY table_schema, table_name
        ");

        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($results) > 0) {
            foreach ($results as $t) {
                echo "  {$t['table_schema']}.{$t['table_name']}\n";
            }
        } else {
            echo "  (none found)\n";
        }
        echo "\n";
    }

    // Check for h_otras_obligaciones specifically
    echo "=== CHECKING h_otras_obligaciones TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name = 'h_otras_obligaciones'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
    ");

    $hotras = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($hotras) > 0) {
        foreach ($hotras as $t) {
            echo "Found: {$t['table_schema']}.{$t['table_name']}\n\n";

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
            echo "First 20 columns:\n";
            foreach ($columns as $col) {
                echo "  - {$col['column_name']} ({$col['data_type']})\n";
            }

            // Get sample data
            echo "\n=== SAMPLE DATA ===\n\n";
            $stmt3 = $pdo->query("SELECT * FROM {$t['table_schema']}.{$t['table_name']} WHERE cvecuenta IS NOT NULL AND cvecuenta > 0 LIMIT 5");
            $samples = $stmt3->fetchAll(PDO::FETCH_ASSOC);

            foreach ($samples as $i => $row) {
                echo "Sample " . ($i + 1) . ":\n";
                $count = 0;
                foreach ($row as $key => $value) {
                    if ($count < 12) {
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
        echo "h_otras_obligaciones table not found\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
