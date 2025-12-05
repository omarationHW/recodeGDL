<?php
try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Verificando campo pago_axosal en cuentapublica:\n\n";

    $stmt = $pdo->query("
        SELECT
            pago_axosal,
            COUNT(*) as cantidad
        FROM catastro_gdl.cuentapublica
        WHERE pago_axosal IS NOT NULL
        GROUP BY pago_axosal
        ORDER BY pago_axosal DESC
        LIMIT 20
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($results) > 0) {
        echo "Valores de pago_axosal encontrados:\n";
        foreach ($results as $row) {
            echo "  Año {$row['pago_axosal']}: {$row['cantidad']} registros\n";
        }

        // Usar el primer año con datos
        $year = $results[0]['pago_axosal'];

        echo "\n\nBuscando registros del año $year:\n";
        $stmt = $pdo->query("
            SELECT
                ctrl.cvecatnva,
                cp.propietario,
                cp.domicilio,
                cp.pago_axosal
            FROM catastro_gdl.controladora ctrl
            INNER JOIN catastro_gdl.cuentapublica cp ON ctrl.cvecuenta = cp.cvecuenta
            WHERE cp.pago_axosal = $year
            LIMIT 5
        ");

        $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "\nEjemplos encontrados:\n";
        foreach ($samples as $i => $row) {
            echo "  " . ($i+1) . ". {$row['cvecatnva']} - {$row['propietario']}\n";
            echo "     Domicilio: {$row['domicilio']}\n";
            echo "     Año: {$row['pago_axosal']}\n\n";
        }
    } else {
        echo "No hay registros con pago_axosal\n";
    }

} catch(Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
