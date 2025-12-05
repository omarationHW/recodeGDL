<?php
// Check descrec table detail

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING DESCREC TABLE STRUCTURE ===\n\n";

    // Check catastro_gdl.descrec
    $schemas = ['catastro_gdl', 'comunX'];

    foreach ($schemas as $schema) {
        echo "Schema: {$schema}\n";
        echo str_repeat("=", 60) . "\n\n";

        // Get columns
        $stmt = $pdo->query("
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = '{$schema}'
            AND table_name = 'descrec'
            ORDER BY ordinal_position
        ");

        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($columns) > 0) {
            echo "Columns:\n";
            foreach ($columns as $col) {
                $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$len}\n";
            }

            // Get sample data
            echo "\nSample data:\n";
            try {
                $stmt = $pdo->query("SELECT * FROM {$schema}.descrec LIMIT 5");
                $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo "Found " . count($samples) . " records\n\n";

                foreach ($samples as $i => $row) {
                    echo "\nRow " . ($i + 1) . ":\n";
                    foreach ($row as $key => $value) {
                        echo "  {$key}: " . ($value ?? 'NULL') . "\n";
                    }
                }
            } catch (Exception $e) {
                echo "  Error reading data: " . $e->getMessage() . "\n";
            }
        } else {
            echo "Table not found or no columns\n";
        }

        echo "\n" . str_repeat("=", 60) . "\n\n";
    }

    // Check if there's a catalog of recargos
    echo "=== CHECKING RECARGOS CATALOG ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'c_recargos'
        ORDER BY ordinal_position
    ");

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    if (count($columns) > 0) {
        echo "Columns:\n";
        foreach ($columns as $col) {
            echo "  - {$col['column_name']}: {$col['data_type']}\n";
        }

        // Get sample
        echo "\nSample c_recargos:\n";
        $stmt = $pdo->query("SELECT * FROM catastro_gdl.c_recargos LIMIT 3");
        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($samples as $i => $row) {
            echo "\nRow " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  {$key}: " . ($value ?? 'NULL') . "\n";
            }
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
