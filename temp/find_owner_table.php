<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== Searching for tables with owner/address columns ===\n\n";

    // Search for tables with columns like 'nombre' or 'propietario'
    $stmt = $pdo->query("
        SELECT DISTINCT table_schema, table_name
        FROM information_schema.columns
        WHERE table_schema IN ('catastro_gdl', 'comun', 'public')
        AND (column_name ILIKE '%nombre%' OR column_name ILIKE '%propietario%' OR column_name ILIKE '%domicilio%')
        ORDER BY table_schema, table_name
        LIMIT 30
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        $schema = $table['table_schema'];
        $name = $table['table_name'];

        // Get columns for each table
        $stmt2 = $pdo->query("
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = '$schema'
            AND table_name = '$name'
            AND (column_name ILIKE '%nombre%' OR column_name ILIKE '%propietario%' OR column_name ILIKE '%domicilio%' OR column_name ILIKE '%calle%' OR column_name ILIKE '%colonia%')
            ORDER BY ordinal_position
        ");

        $cols = $stmt2->fetchAll(PDO::FETCH_COLUMN);

        if (count($cols) > 0) {
            echo "$schema.$name:\n";
            echo "  Columns: " . implode(', ', $cols) . "\n";

            // Get sample data
            $stmt3 = $pdo->query("SELECT * FROM $schema.$name LIMIT 1");
            $sample = $stmt3->fetch(PDO::FETCH_ASSOC);

            if ($sample) {
                echo "  Sample row keys: " . implode(', ', array_keys($sample)) . "\n";
            }
            echo "\n";
        }
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
