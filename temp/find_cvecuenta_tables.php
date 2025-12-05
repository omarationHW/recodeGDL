<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Tables with cvecuenta column and owner/address info ===\n\n";

    $stmt = $pdo->query("
        SELECT t1.table_schema, t1.table_name
        FROM information_schema.columns t1
        WHERE t1.table_schema IN ('catastro_gdl')
        AND t1.column_name = 'cvecuenta'
        AND EXISTS (
            SELECT 1 FROM information_schema.columns t2
            WHERE t2.table_schema = t1.table_schema
            AND t2.table_name = t1.table_name
            AND (t2.column_name ILIKE '%nombre%' OR t2.column_name ILIKE '%propietario%')
        )
        ORDER BY t1.table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        $schema = $table['table_schema'];
        $name = $table['table_name'];

        echo "$schema.$name\n";

        // Get relevant columns
        $stmt2 = $pdo->query("
            SELECT column_name, data_type
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = '$name'
            AND (
                column_name IN ('cvecuenta', 'cuenta', 'cvecatnva') OR
                column_name ILIKE '%nombre%' OR
                column_name ILIKE '%propietario%' OR
                column_name ILIKE '%domicilio%' OR
                column_name ILIKE '%calle%' OR
                column_name ILIKE '%colonia%'
            )
            ORDER BY ordinal_position
        ");

        $cols = $stmt2->fetchAll(PDO::FETCH_ASSOC);
        foreach ($cols as $col) {
            echo "  - {$col['column_name']} ({$col['data_type']})\n";
        }

        // Get row count
        $stmt3 = $pdo->query("SELECT COUNT(*) as cnt FROM $schema.$name");
        $count = $stmt3->fetch(PDO::FETCH_ASSOC);
        echo "  Row count: {$count['cnt']}\n";

        // Sample data
        $stmt4 = $pdo->query("SELECT * FROM $schema.$name LIMIT 1");
        $sample = $stmt4->fetch(PDO::FETCH_ASSOC);
        if ($sample && isset($sample['cvecuenta'])) {
            echo "  Sample cvecuenta: {$sample['cvecuenta']}\n";
            foreach ($cols as $col) {
                $colname = $col['column_name'];
                if (isset($sample[$colname]) && $sample[$colname] !== null && $sample[$colname] !== '') {
                    echo "  Sample $colname: " . substr($sample[$colname], 0, 50) . "\n";
                }
            }
        }

        echo "\n";
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
