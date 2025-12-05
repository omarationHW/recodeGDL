<?php
// Check descmultas and related tables structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR MULTAS DESCUENTOS TABLES ===\n\n";

    // Search for tables with descmul or multa in name
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE (table_name LIKE '%descmul%' OR table_name LIKE '%multa%')
        AND table_schema IN ('comun', 'comunX', 'multas_reglamentos', 'public')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($tables) . " tables:\n\n";

    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    echo "\n=== CHECKING DESCMULMPAL TABLE ===\n\n";

    // Try to find the specific table
    $stmt = $pdo->query("
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_name LIKE '%descmul%pal%'
    ");

    $descmulpal = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($descmulpal) > 0) {
        foreach ($descmulpal as $table) {
            $schema = $table['table_schema'];
            $tname = $table['table_name'];
            echo "Found: {$schema}.{$tname}\n\n";

            // Get column structure
            $stmt = $pdo->query("
                SELECT column_name, data_type, character_maximum_length
                FROM information_schema.columns
                WHERE table_schema = '{$schema}'
                AND table_name = '{$tname}'
                ORDER BY ordinal_position
            ");

            $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo "Columns:\n";
            foreach ($columns as $col) {
                $len = $col['character_maximum_length'] ? "({$col['character_maximum_length']})" : "";
                echo "  - {$col['column_name']}: {$col['data_type']}{$len}\n";
            }

            // Get sample data
            echo "\nSample data:\n";
            $stmt = $pdo->query("SELECT * FROM {$schema}.{$tname} LIMIT 3");
            $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
            foreach ($samples as $i => $row) {
                echo "\nRow " . ($i + 1) . ":\n";
                foreach ($row as $key => $value) {
                    echo "  {$key}: " . ($value ?? 'NULL') . "\n";
                }
            }
        }
    } else {
        echo "No descmulmpal table found. Checking for similar tables...\n\n";

        // Check for general multas table
        $stmt = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name = 'ta_48_multas'
        ");

        $multas = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($multas) > 0) {
            foreach ($multas as $table) {
                $schema = $table['table_schema'];
                echo "Found multas table: {$schema}.ta_48_multas\n\n";

                $stmt = $pdo->query("
                    SELECT column_name, data_type
                    FROM information_schema.columns
                    WHERE table_schema = '{$schema}'
                    AND table_name = 'ta_48_multas'
                    ORDER BY ordinal_position
                ");

                $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
                echo "Columns:\n";
                foreach ($columns as $col) {
                    echo "  - {$col['column_name']}: {$col['data_type']}\n";
                }
            }
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
