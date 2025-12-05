<?php
// Find tables with propietario and domicilio columns

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== TABLES WITH 'propietario' COLUMN ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'propietario'
        AND table_schema IN ('catastro_gdl', 'comun', 'comunX')
        ORDER BY table_schema, table_name
        LIMIT 20
    ");

    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($tables as $table) {
        echo "{$table['table_schema']}.{$table['table_name']}\n";
    }

    // Check the construc table specifically
    echo "\n=== CHECKING catastro_gdl.construc TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'construc'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    // Get sample data from construc
    echo "\n=== SAMPLE FROM catastro_gdl.construc ===\n\n";

    $stmt = $pdo->query("
        SELECT cvecatnva, propietario, domicilio, colonia, tipoconstruc
        FROM catastro_gdl.construc
        WHERE cvecatnva IS NOT NULL AND cvecatnva != ''
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

    // Check convcta table which might have more complete info
    echo "=== CHECKING catastro_gdl.convcta TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'convcta'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    echo "\n=== SAMPLE FROM catastro_gdl.convcta ===\n\n";

    $stmt = $pdo->query("
        SELECT cvecatnva, cvecuenta, propietario, domicilio
        FROM catastro_gdl.convcta
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

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
