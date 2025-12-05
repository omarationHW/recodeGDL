<?php
// Check descrecmerc data

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING descrecmerc DATA ===\n\n";

    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM comun.descrecmerc
    ");

    $count = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total records in descrecmerc: {$count['total']}\n\n";

    if ($count['total'] > 0) {
        echo "=== SAMPLE RECORDS ===\n\n";

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
    }

    echo "=== COMPLETE QUERY WITH JOIN ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.id_local,
            l.num_mercado,
            l.local,
            l.nombre,
            l.giro,
            d.porcentaje,
            d.axoini,
            d.axofin,
            d.estado,
            d.fecalta,
            d.autoriza
        FROM comun.ta_11_locales l
        LEFT JOIN comun.descrecmerc d ON l.id_local = d.id_local
        WHERE d.id_descto IS NOT NULL
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($samples) . " locales with descuentos\n\n";

    foreach ($samples as $i => $row) {
        echo "Local " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    // Try getting by clave_catastral
    echo "\n=== GETTING LOCALES BY CLAVE_CATASTRAL ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.id_local,
            l.clave_catastral,
            l.nombre,
            l.giro
        FROM comun.ta_11_locales l
        WHERE l.clave_catastral IS NOT NULL
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Local " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  $key: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
