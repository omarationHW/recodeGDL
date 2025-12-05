<?php
// Get valid descuentos prediales with cvecuenta > 0

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== GETTING VALID DESCUENTOS PREDIALES (cvecuenta > 0) ===\n\n";

    // Get descpred with catalog details where cvecuenta > 0
    $stmt = $pdo->query("
        SELECT
            d.cvecuenta,
            d.cvedescuento,
            c.descripcion as desc_nombre,
            c.porcentaje,
            c.axodescto as ejercicio,
            d.bimini,
            d.bimfin,
            d.fecalta,
            d.captalta,
            d.status,
            d.solicitante,
            d.observaciones
        FROM catastro_gdl.descpred d
        INNER JOIN catastro_gdl.c_descpred c ON d.cvedescuento = c.cvedescuento
        WHERE d.cvecuenta > 0
        ORDER BY d.cvecuenta
        LIMIT 10
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($samples) . " descuentos\n\n";

    foreach ($samples as $i => $row) {
        echo "═══════════════════════════════════════════════════════════\n";
        echo "Muestra " . ($i + 1) . ":\n";
        echo "═══════════════════════════════════════════════════════════\n";
        echo "CVE Cuenta: {$row['cvecuenta']}\n";
        echo "Tipo Descuento: {$row['cvedescuento']}\n";
        echo "Descripción: {$row['desc_nombre']}\n";
        echo "Porcentaje: {$row['porcentaje']}%\n";
        echo "Ejercicio: {$row['ejercicio']}\n";
        echo "Bimestres: {$row['bimini']} - {$row['bimfin']}\n";
        echo "Fecha Alta: {$row['fecalta']}\n";
        echo "Status: {$row['status']} (" . ($row['status'] == 'V' ? 'Vigente' : 'Cancelado') . ")\n";
        echo "Solicitante: " . trim($row['solicitante'] ?? 'NULL') . "\n";
        echo "Observaciones: " . ($row['observaciones'] ?? 'Sin observaciones') . "\n\n";
    }

    // Get specific cuentas for testing
    echo "=== 3 CUENTAS PARA PRUEBAS ===\n\n";

    $stmt = $pdo->query("
        SELECT
            d.cvecuenta,
            COUNT(*) as num_descuentos,
            STRING_AGG(DISTINCT d.status, ',') as estados
        FROM catastro_gdl.descpred d
        WHERE d.cvecuenta > 0
        GROUP BY d.cvecuenta
        HAVING COUNT(*) > 0
        ORDER BY d.cvecuenta
        LIMIT 10
    ");

    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cuentas as $i => $row) {
        echo ($i + 1) . ". CVE Cuenta: {$row['cvecuenta']} ({$row['num_descuentos']} descuentos, status: {$row['estados']})\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
