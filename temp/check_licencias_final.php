<?php
// Final check of licencias data

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== DERECHOS POR LICENCIA (COMPLETE DATA) ===\n\n";

    $stmt = $pdo->query("
        SELECT
            l.licencia,
            l.id_licencia,
            l.propietario,
            l.actividad,
            l.domicilio,
            s.derechos,
            s.recargos,
            s.multas,
            s.total
        FROM catastro_gdl.licencias l
        JOIN catastro_gdl.saldos_lic s ON l.id_licencia = s.id_licencia
        WHERE l.licencia > 0
        AND s.derechos > 0
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Found " . count($samples) . " records with derechos > 0\n\n";

    foreach ($samples as $i => $row) {
        echo "Licencia " . ($i + 1) . ":\n";
        echo "  Número Licencia: {$row['licencia']}\n";
        echo "  Propietario: " . trim($row['propietario']) . "\n";
        echo "  Actividad: " . trim($row['actividad']) . "\n";
        echo "  Derechos: $" . number_format($row['derechos'], 2) . "\n";
        echo "  Recargos: $" . number_format($row['recargos'], 2) . "\n";
        echo "  Multas: $" . number_format($row['multas'], 2) . "\n";
        echo "  Total: $" . number_format($row['total'], 2) . "\n\n";
    }

    // Check detsal_lic structure
    echo "=== DETSAL_LIC STRUCTURE ===\n\n";

    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'catastro_gdl'
        AND table_name = 'detsal_lic'
        ORDER BY ordinal_position
    ");

    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cols as $col) {
        echo "{$col['column_name']}: {$col['data_type']}\n";
    }

    // Get detail for a specific license
    if (count($samples) > 0) {
        $licencia = $samples[0]['licencia'];

        echo "\n\n=== DETALLE POR AÑO PARA LICENCIA $licencia ===\n\n";

        $stmt = $pdo->prepare("
            SELECT
                d.axo,
                d.derechos,
                d.recargos,
                d.cvepago
            FROM catastro_gdl.detsal_lic d
            JOIN catastro_gdl.licencias l ON d.id_licencia = l.id_licencia
            WHERE l.licencia = :licencia
            AND d.derechos > 0
            ORDER BY d.axo DESC
            LIMIT 5
        ");

        $stmt->execute(['licencia' => $licencia]);
        $details = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($details as $det) {
            echo "Año {$det['axo']}: Derechos=\${$det['derechos']}, Recargos=\${$det['recargos']}, Pagado=" . ($det['cvepago'] > 0 ? 'Sí' : 'No') . "\n";
        }
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
