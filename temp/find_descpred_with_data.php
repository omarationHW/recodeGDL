<?php
// Find descpred tables with data

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING DESCPRED TABLES WITH DATA ===\n\n";

    $tables = ['descpredial', 'descpred', 'c_descpred'];
    $schemas = ['catastro_gdl', 'comun', 'comunX'];

    foreach ($tables as $table) {
        foreach ($schemas as $schema) {
            try {
                $stmt = $pdo->query("SELECT COUNT(*) as count FROM {$schema}.{$table}");
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                if ($result['count'] > 0) {
                    echo "{$schema}.{$table}: {$result['count']} records\n";

                    // Get structure
                    $stmt = $pdo->query("
                        SELECT column_name, data_type
                        FROM information_schema.columns
                        WHERE table_schema = '{$schema}'
                        AND table_name = '{$table}'
                        ORDER BY ordinal_position
                    ");
                    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    echo "  Columns: " . implode(', ', array_column($columns, 'column_name')) . "\n";

                    // Get sample
                    $stmt = $pdo->query("SELECT * FROM {$schema}.{$table} LIMIT 1");
                    $sample = $stmt->fetch(PDO::FETCH_ASSOC);
                    if ($sample) {
                        echo "  Sample:\n";
                        foreach ($sample as $key => $value) {
                            echo "    {$key}: " . ($value ?? 'NULL') . "\n";
                        }
                    }
                    echo "\n";
                }
            } catch (Exception $e) {
                // Table doesn't exist, skip
            }
        }
    }

    // Check catastro for cvecat alternative
    echo "=== CHECKING CATASTRO TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'catastro'
        AND column_name LIKE '%cve%'
        ORDER BY ordinal_position
    ");
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Columns with 'cve':\n";
    foreach ($columns as $col) {
        echo "  - {$col['column_name']}\n";
    }

    // Get sample from catastro
    echo "\nSample catastro data:\n";
    $stmt = $pdo->query("SELECT cvecuenta, cvemov, cvevalor FROM catastro_gdl.catastro LIMIT 3");
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($samples as $i => $row) {
        echo "Row " . ($i + 1) . ": cvecuenta={$row['cvecuenta']}, cvemov={$row['cvemov']}, cvevalor={$row['cvevalor']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
