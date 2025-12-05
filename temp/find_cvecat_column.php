<?php
// Find tables with cvecat column

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== TABLES WITH 'cvecat' COLUMN ===\n\n";

    $stmt = $pdo->query("
        SELECT
            table_schema,
            table_name,
            column_name,
            data_type,
            character_maximum_length
        FROM information_schema.columns
        WHERE column_name LIKE '%cvecat%'
        AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'multas_reglamentos', 'public')
        ORDER BY table_schema, table_name
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($results) . " columns with 'cvecat':\n\n";

    foreach ($results as $row) {
        $type = $row['data_type'];
        if ($row['character_maximum_length']) {
            $type .= "({$row['character_maximum_length']})";
        }
        echo "{$row['table_schema']}.{$row['table_name']}.{$row['column_name']} : {$type}\n";
    }

    // Now let's check the valor table specifically
    echo "\n=== CHECKING catastro_gdl.valor TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'valor'
        ORDER BY ordinal_position
        LIMIT 20
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    // Get a sample record from valor table
    echo "\n=== SAMPLE FROM catastro_gdl.valor ===\n\n";
    $stmt = $pdo->query("SELECT cvecat, propietario, direccion FROM catastro_gdl.valor WHERE cvecat IS NOT NULL LIMIT 3");
    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Record " . ($i + 1) . ":\n";
        echo "  cvecat: {$row['cvecat']}\n";
        echo "  propietario: {$row['propietario']}\n";
        echo "  direccion: {$row['direccion']}\n\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
