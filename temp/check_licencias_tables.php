<?php
// Check licencias tables structure

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING LICENCIAS TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'licencias'
        ORDER BY ordinal_position
        LIMIT 30
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols) > 0) {
        foreach ($cols as $col) {
            $type = $col['data_type'];
            if ($col['character_maximum_length']) {
                $type .= "({$col['character_maximum_length']})";
            }
            echo "{$col['column_name']}: {$type}\n";
        }

        echo "\n=== SAMPLE FROM LICENCIAS ===\n\n";

        $stmt = $pdo->query("
            SELECT licencia, id_licencia, propietario, vigente, giro
            FROM catastro_gdl.licencias
            WHERE licencia IS NOT NULL
            LIMIT 3
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($samples as $i => $row) {
            echo "Licencia " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
            echo "\n";
        }
    }

    echo "\n=== CHECKING SALDOS_LIC TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'saldos_lic'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols) > 0) {
        foreach ($cols as $col) {
            echo "{$col['column_name']}: {$col['data_type']}\n";
        }

        echo "\n=== SAMPLE FROM SALDOS_LIC ===\n\n";

        $stmt = $pdo->query("
            SELECT id_licencia, derechos, multas, otros
            FROM catastro_gdl.saldos_lic
            WHERE derechos > 0
            LIMIT 3
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($samples as $i => $row) {
            echo "Saldo " . ($i + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "  $key: " . ($value ?? 'NULL') . "\n";
            }
            echo "\n";
        }
    }

    echo "\n=== CHECKING DETSAL_LIC TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'detsal_lic'
        ORDER BY ordinal_position
        LIMIT 20
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($cols) > 0) {
        foreach ($cols as $col) {
            echo "{$col['column_name']}: {$col['data_type']}\n";
        }
    }

    // Get a sample with JOIN to see complete information
    echo "\n\n=== COMPLETE QUERY SAMPLE (JOIN) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.licencia,
            l.id_licencia,
            l.propietario,
            l.giro,
            s.derechos,
            s.multas,
            s.otros
        FROM catastro_gdl.licencias l
        JOIN catastro_gdl.saldos_lic s ON l.id_licencia = s.id_licencia
        WHERE l.licencia IS NOT NULL
        AND s.derechos > 0
        LIMIT 3
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
