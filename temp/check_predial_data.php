<?php
// Check for predial data structures

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SAMPLE FROM CONTROLADORA (just cvecatnva and cvecuenta) ===\n\n";

    $stmt = $pdo->query("
        SELECT cvecatnva, cvecuenta, cvevalor, vigente, saldo
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

    // Check if there's a cvecatastral table
    echo "=== CHECKING catastro_gdl.cvecatastral TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'cvecatastral'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    // Get sample from cvecatastral
    echo "\n=== SAMPLE FROM cvecatastral ===\n\n";

    $stmt = $pdo->query("
        SELECT cvecatnva, propietario, domicilio, colonia
        FROM catastro_gdl.cvecatastral
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

    // Check construc table
    echo "=== CHECKING catastro_gdl.construc TABLE (sample) ===\n\n";

    $stmt = $pdo->query("
        SELECT cvecatnva, superficie, frente, fondo, tipoconstruc
        FROM catastro_gdl.construc
        WHERE cvecatnva IS NOT NULL
        LIMIT 2
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
