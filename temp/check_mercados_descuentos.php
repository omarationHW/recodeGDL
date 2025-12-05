<?php
// Check mercados and descuentos tables

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING comun.ta_12_descuentos TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_12_descuentos'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        $type = $col['data_type'];
        if ($col['character_maximum_length']) {
            $type .= "({$col['character_maximum_length']})";
        }
        echo "{$col['column_name']}: {$type}\n";
    }

    echo "\n=== SAMPLE FROM ta_12_descuentos ===\n\n";

    $stmt = $pdo->query("
        SELECT *
        FROM comun.ta_12_descuentos
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    echo "\n=== CHECKING comun.descrecmerc TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'descrecmerc'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    echo "\n=== SAMPLE FROM descrecmerc ===\n\n";

    $stmt = $pdo->query("
        SELECT *
        FROM comun.descrecmerc
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Registro " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    echo "\n=== CHECKING comun.ta_11_locales TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_11_locales'
        ORDER BY ordinal_position
        LIMIT 20
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    echo "\n=== SAMPLE WITH JOIN (locales + descuentos) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.id_local,
            l.clave_catastral,
            l.giro,
            d.axoini,
            d.mesini,
            d.axofin,
            d.mesfin,
            d.porcentaje,
            d.estado
        FROM comun.ta_11_locales l
        LEFT JOIN comun.ta_12_descuentos d ON l.id_local = d.id_local
        WHERE l.id_local IS NOT NULL
        LIMIT 5
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
