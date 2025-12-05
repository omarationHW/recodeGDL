<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== EXPLORANDO DATOS DE CALIFICACIÓN DE MULTAS ===\n\n";

    // Obtener ejemplos de multas con cuenta específica
    $sql = "
        SELECT
            id_multa,
            cvepago,
            num_acta,
            axo_acta,
            fecha_acta,
            contribuyente,
            domicilio,
            id_ley,
            id_infraccion,
            calificacion,
            multa,
            gastos,
            total,
            observacion
        FROM comun.multas
        WHERE cvepago IS NOT NULL
        AND cvepago > 0
        ORDER BY RANDOM()
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "EJEMPLOS DE MULTAS CON CUENTA (PARA CALIFICACIÓN):\n";
    echo "===================================================\n\n";

    foreach ($ejemplos as $i => $ej) {
        $num = $i + 1;
        echo "EJEMPLO $num:\n";
        echo "  Cuenta (cvepago): {$ej['cvepago']}\n";
        echo "  ID Multa: {$ej['id_multa']}\n";
        echo "  Folio: {$ej['num_acta']}\n";
        echo "  Año: {$ej['axo_acta']}\n";
        echo "  Fecha: {$ej['fecha_acta']}\n";
        echo "  Contribuyente: {$ej['contribuyente']}\n";
        echo "  Domicilio: {$ej['domicilio']}\n";
        echo "  Ley/Infracción: {$ej['id_ley']}/{$ej['id_infraccion']}\n";
        echo "  Calificación: \${$ej['calificacion']}\n";
        echo "  Multa: \${$ej['multa']}\n";
        echo "  Gastos: \${$ej['gastos']}\n";
        echo "  Total: \${$ej['total']}\n";
        echo "  Observación: {$ej['observacion']}\n";
        echo "\n";
    }

    // Buscar cuentas con múltiples multas
    echo "\n=== CUENTAS CON MÚLTIPLES MULTAS ===\n\n";

    $sql2 = "
        SELECT
            cvepago,
            COUNT(*) as total_multas,
            SUM(total) as suma_total,
            MIN(axo_acta) as primer_anio,
            MAX(axo_acta) as ultimo_anio
        FROM comun.multas
        WHERE cvepago IS NOT NULL
        AND cvepago > 0
        GROUP BY cvepago
        HAVING COUNT(*) > 1
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ";

    $stmt2 = $pdo->query($sql2);
    $cuentas = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Cuentas con más multas:\n";
    foreach ($cuentas as $cuenta) {
        echo "  Cuenta: {$cuenta['cvepago']}, Total Multas: {$cuenta['total_multas']}, Suma Total: \${$cuenta['suma_total']}, Años: {$cuenta['primer_anio']}-{$cuenta['ultimo_anio']}\n";
    }

    // Obtener detalle de una cuenta específica con múltiples multas
    if (count($cuentas) > 0) {
        $cuentaEjemplo = $cuentas[0]['cvepago'];

        echo "\n\n=== DETALLE DE CUENTA: $cuentaEjemplo ===\n\n";

        $sql3 = "
            SELECT
                id_multa,
                num_acta,
                axo_acta,
                fecha_acta,
                contribuyente,
                calificacion,
                multa,
                gastos,
                total
            FROM comun.multas
            WHERE cvepago = :cuenta
            ORDER BY fecha_acta DESC
            LIMIT 10
        ";

        $stmt3 = $pdo->prepare($sql3);
        $stmt3->execute(['cuenta' => $cuentaEjemplo]);
        $detalle = $stmt3->fetchAll(PDO::FETCH_ASSOC);

        echo "Total de multas para esta cuenta: " . count($detalle) . "\n\n";
        foreach ($detalle as $d) {
            echo "  Folio: {$d['num_acta']}, Año: {$d['axo_acta']}, Fecha: {$d['fecha_acta']}, Total: \${$d['total']}\n";
        }
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
