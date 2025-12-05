<?php
// Search for tables with folio column

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR TABLES WITH 'FOLIO' COLUMN ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name, column_name
        FROM information_schema.columns
        WHERE column_name = 'folio'
        AND table_schema IN ('comun', 'comunX', 'catastro_gdl', 'multas_reglamentos')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($tables) . " tables with 'folio' column:\n\n";

    $grouped = [];
    foreach ($tables as $table) {
        $key = "{$table['table_schema']}.{$table['table_name']}";
        $grouped[$key] = true;
    }

    foreach (array_keys($grouped) as $table_name) {
        echo "$table_name\n";
    }

    // Now check which of these are related to fosa/panteones
    echo "\n=== CHECKING RELATED TABLES ===\n\n";

    $related_tables = ['ta_48_multas', 'h_fosa', 'fosa', 'panteones', 'derechos_fosa'];

    foreach ($related_tables as $tname) {
        $stmt = $pdo->query("
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_name LIKE '%{$tname}%'
            AND table_schema IN ('comun', 'comunX', 'catastro_gdl')
        ");

        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (count($results) > 0) {
            echo "Tables matching '{$tname}':\n";
            foreach ($results as $table) {
                echo "  {$table['table_schema']}.{$table['table_name']}\n";
            }
        }
    }

    // Let's use id_control as the search parameter instead
    echo "\n=== SAMPLE ID_CONTROLS FOR TESTING ===\n\n";

    $stmt = $pdo->query("
        SELECT id_control, cem, clase, secc, linea, fosa, nombre
        FROM catastro_gdl.v_fosa
        ORDER BY id_control
        LIMIT 10
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($samples as $i => $row) {
        echo ($i + 1) . ". ID: {$row['id_control']} - {$row['nombre']} (Cem:{$row['cem']}, Fosa:{$row['fosa']})\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
