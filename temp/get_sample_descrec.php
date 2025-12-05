<?php
// Get sample descrec data

try {
    $pdo = new PDO(
        'pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias',
        'refact',
        'FF)-BQk2'
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== GETTING SAMPLE DESCREC DATA ===\n\n";

    // Get descrec with different status
    $stmt = $pdo->query("
        SELECT
            cvecuenta,
            axoini,
            bimini,
            axofin,
            bimfin,
            porcentaje,
            fecalta,
            captalta,
            fecbaja,
            captbaja,
            vigencia
        FROM catastro_gdl.descrec
        WHERE vigencia IN ('P', 'V', 'C')
        ORDER BY cvecuenta
        LIMIT 20
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Found " . count($samples) . " records\n\n";

    foreach ($samples as $i => $row) {
        echo "═══════════════════════════════════════════════════════════\n";
        echo "Muestra " . ($i + 1) . ":\n";
        echo "═══════════════════════════════════════════════════════════\n";
        echo "CVE Cuenta: {$row['cvecuenta']}\n";
        echo "Periodo: {$row['axoini']}/{$row['bimini']} - {$row['axofin']}/{$row['bimfin']}\n";
        echo "Porcentaje Descuento: {$row['porcentaje']}%\n";
        echo "Fecha Alta: {$row['fecalta']}\n";
        echo "Capturista Alta: " . trim($row['captalta']) . "\n";
        echo "Vigencia: {$row['vigencia']} (" . (
            $row['vigencia'] == 'V' ? 'Vigente' :
            ($row['vigencia'] == 'P' ? 'Pagado' : 'Cancelado')
        ) . ")\n";
        if ($row['fecbaja']) {
            echo "Fecha Baja: {$row['fecbaja']}\n";
            echo "Capturista Baja: " . trim($row['captbaja']) . "\n";
        }
        echo "\n";
    }

    // Get distinct cuentas for testing
    echo "\n=== CUENTAS PARA PRUEBAS ===\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT cvecuenta, vigencia, porcentaje
        FROM catastro_gdl.descrec
        WHERE vigencia = 'P'
        ORDER BY cvecuenta
        LIMIT 10
    ");

    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Primeras 10 cuentas con descuentos:\n";
    foreach ($cuentas as $i => $row) {
        echo ($i + 1) . ". cvecuenta: {$row['cvecuenta']} ({$row['porcentaje']}%, vigencia: {$row['vigencia']})\n";
    }

    // Count total
    echo "\n=== ESTADÍSTICAS ===\n\n";

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM catastro_gdl.descrec");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Total de descuentos de recargos: {$total['total']}\n";

    $stmt = $pdo->query("SELECT vigencia, COUNT(*) as count FROM catastro_gdl.descrec GROUP BY vigencia ORDER BY vigencia");
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "\nPor vigencia:\n";
    foreach ($stats as $stat) {
        echo "  {$stat['vigencia']}: {$stat['count']} descuentos\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
