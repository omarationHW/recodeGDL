<?php
// Check controladora table for predial information

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CONTROLADORA TABLE STRUCTURE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length, numeric_precision
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'controladora'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Total columns: " . count($cols) . "\n\n";

    foreach ($cols as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        } elseif ($col['numeric_precision']) {
            $type .= "({$col['numeric_precision']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== SAMPLE DATA FROM CONTROLADORA (3 records) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            cvecatnva,
            cvecuenta,
            propietario,
            domicilio,
            colonia,
            cvemun,
            superf,
            frente,
            fondo,
            tipoprop,
            clasepredio
        FROM catastro_gdl.controladora
        WHERE cvecatnva IS NOT NULL
        LIMIT 3
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Record " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    echo "=== COUNT RECORDS ===\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.controladora WHERE cvecatnva IS NOT NULL");
    $count = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total records with cvecatnva: {$count['total']}\n";

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
