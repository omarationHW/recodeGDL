<?php
// Check multas with descmultampal join

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CHECKING MULTAS WITH DESCMULTAMPAL ===\n\n";

    $stmt = $pdo->query("
        SELECT
            m.id_multa,
            m.num_acta,
            m.fecha_acta,
            m.contribuyente,
            m.domicilio,
            m.num_licencia,
            m.giro,
            m.multa,
            m.total,
            d.tipo_descto,
            d.valor,
            d.estado as estado_desc,
            d.feccap as fecha_descuento,
            d.observacion as obs_descuento,
            d.autoriza
        FROM catastro_gdl.multas m
        INNER JOIN catastro_gdl.descmultampal d ON m.id_multa = d.id_multa
        WHERE d.estado = 'V'
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($samples) . " multas with descuentos vigentes\n\n";

    foreach ($samples as $i => $row) {
        echo "Multa " . ($i + 1) . ":\n";
        foreach ($row as $key => $value) {
            echo "  {$key}: " . ($value ?? 'NULL') . "\n";
        }
        echo "\n";
    }

    // Check what id_multas have descuentos
    echo "\n=== CHECKING ID_MULTAS WITH DESCUENTOS ===\n\n";

    $stmt = $pdo->query("
        SELECT
            d.id_multa,
            COUNT(*) as num_descuentos,
            STRING_AGG(d.estado, ',') as estados
        FROM catastro_gdl.descmultampal d
        GROUP BY d.id_multa
        ORDER BY d.id_multa
        LIMIT 10
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "ID Multas with descuentos:\n\n";
    foreach ($results as $row) {
        echo "ID Multa {$row['id_multa']}: {$row['num_descuentos']} descuentos ({$row['estados']})\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
