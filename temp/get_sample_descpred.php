<?php
// Get sample descuentos prediales

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== GETTING SAMPLE DESCUENTOS PREDIALES ===\n\n";

    // Get descpred with catalog details
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
        WHERE d.status = 'V'
        ORDER BY d.cvecuenta
        LIMIT 5
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($samples) . " descuentos vigentes\n\n";

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
        echo "Capturista: {$row['captalta']}\n";
        echo "Status: {$row['status']} (Vigente)\n";
        echo "Solicitante: " . ($row['solicitante'] ?? 'NULL') . "\n";
        echo "Observaciones: " . ($row['observaciones'] ?? 'Sin observaciones') . "\n\n";
    }

    // If no vigentes, try with status 'C' (Cancelado)
    if (count($samples) == 0) {
        echo "No hay descuentos vigentes, buscando cancelados...\n\n";

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
                d.status,
                d.solicitante
            FROM catastro_gdl.descpred d
            INNER JOIN catastro_gdl.c_descpred c ON d.cvedescuento = c.cvedescuento
            WHERE d.status = 'C'
            ORDER BY d.cvecuenta
            LIMIT 10
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "Found " . count($samples) . " descuentos cancelados\n\n";

        foreach ($samples as $i => $row) {
            echo "Muestra " . ($i + 1) . ":\n";
            echo "  CVE Cuenta: {$row['cvecuenta']}\n";
            echo "  Descripción: {$row['desc_nombre']}\n";
            echo "  Porcentaje: {$row['porcentaje']}%\n";
            echo "  Status: {$row['status']} (Cancelado)\n\n";
        }
    }

    // Get distinct cvecuenta for testing
    echo "\n=== CUENTAS PARA PRUEBAS ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT d.cvecuenta
        FROM catastro_gdl.descpred d
        ORDER BY d.cvecuenta
        LIMIT 10
    ");

    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Primeras 10 cuentas con descuentos:\n";
    foreach ($cuentas as $i => $row) {
        echo ($i + 1) . ". cvecuenta: {$row['cvecuenta']}\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
