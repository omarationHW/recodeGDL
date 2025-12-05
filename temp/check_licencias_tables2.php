<?php
// Check licencias tables structure (fixed)

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== SAMPLE FROM LICENCIAS ===\n\n";

    $stmt = $pdo->query("
        SELECT licencia, id_licencia, propietario, actividad
        FROM catastro_gdl.licencias
        WHERE licencia IS NOT NULL
        LIMIT 3
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($samples as $i => $row) {
        echo "Licencia " . ($i + 1) . ":\n";
        echo "  Número: {$row['licencia']}\n";
        echo "  ID: {$row['id_licencia']}\n";
        echo "  Propietario: {$row['propietario']}\n";
        echo "  Actividad: {$row['actividad']}\n\n";
    }

    echo "=== CHECKING SALDOS_LIC TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'saldos_lic'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

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

    echo "=== CHECKING DETSAL_LIC TABLE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'detsal_lic'
        ORDER BY ordinal_position
        LIMIT 15
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    // Complete query to understand the relationship
    echo "\n\n=== COMPLETE QUERY (DERECHOS BY LICENCIA) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.licencia,
            l.propietario,
            l.actividad,
            s.derechos as total_derechos,
            d.axo,
            d.derechos as derechos_anio,
            d.cvepago
        FROM catastro_gdl.licencias l
        JOIN catastro_gdl.saldos_lic s ON l.id_licencia = s.id_licencia
        LEFT JOIN catastro_gdl.detsal_lic d ON l.id_licencia = d.id_licencia
        WHERE l.licencia IS NOT NULL
        AND s.derechos > 0
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
