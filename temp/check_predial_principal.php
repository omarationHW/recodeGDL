<?php
// Check for predial_principal table/view

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SEARCHING FOR predial TABLES/VIEWS ===\n\n";

    $stmt = $pdo->query("
        SELECT table_schema, table_name, table_type
        FROM information_schema.tables
        WHERE table_name LIKE '%predial%'
        AND table_schema IN ('catastro_gdl', 'comun', 'comunX', 'public', 'multas_reglamentos')
        ORDER BY table_schema, table_name
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['table_type']}: {$table['table_schema']}.{$table['table_name']}\n";
    }

    // Let's try a simple query based on what we know
    // The user is searching by cvecat, so let's build a query that joins controladora with other tables
    echo "\n\n=== TESTING JOIN QUERY ===\n\n";

    // Try to get predial info by joining controladora with other tables
    $cvecat = 'D65I3950016'; // From our previous sample

    $stmt = $pdo->prepare("
        SELECT
            ctrl.cvecatnva,
            ctrl.cvecuenta,
            ctrl.vigente,
            ctrl.saldo,
            ctrl.val1_valfiscal,
            ctrl.val1_areaterr,
            ctrl.val1_areaconst
        FROM catastro_gdl.controladora ctrl
        WHERE ctrl.cvecatnva = :cvecat
        LIMIT 1
    ");

    $stmt->execute(['cvecat' => $cvecat]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo "Found record for cvecat: $cvecat\n\n";
        foreach ($result as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
    } else {
        echo "No record found for cvecat: $cvecat\n";
    }

    // Check for adeudo_predial table
    echo "\n\n=== CHECKING catastro_gdl.adeudo_predial ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'adeudo_predial'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols) > 0) {
        foreach ($cols as $col) {
            echo "{$col['column_name']}: {$col['data_type']}\n";
        }

        echo "\n=== SAMPLE FROM adeudo_predial ===\n\n";

        $stmt = $pdo->query("
            SELECT *
            FROM catastro_gdl.adeudo_predial
            LIMIT 1
        ");

        $sample = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($sample) {
            foreach ($sample as $key => $value) {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
        }
    } else {
        echo "Table adeudo_predial not found or has no columns\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
