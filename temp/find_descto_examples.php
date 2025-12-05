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

    echo "=== BUSCANDO CUENTAS CON MÚLTIPLES DESCUENTOS ===\n\n";

    // Buscar cuentas con varios descuentos y obtener el año de la multa
    $sql = "
        SELECT
            d.cvepago,
            EXTRACT(YEAR FROM m.fecha_acta) as ejercicio,
            COUNT(*) as total_descuentos,
            SUM(d.valor) as suma_valores
        FROM comun.h_descmultampal d
        INNER JOIN comun.multas m ON d.id_multa = m.id_multa
        WHERE d.cvepago IS NOT NULL
        AND m.fecha_acta IS NOT NULL
        GROUP BY d.cvepago, EXTRACT(YEAR FROM m.fecha_acta)
        HAVING COUNT(*) >= 3
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sql);
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "TOP 5 CUENTAS CON MÁS DESCUENTOS:\n";
    echo "===================================\n\n";

    foreach ($cuentas as $i => $c) {
        $num = $i + 1;
        echo "$num. Cuenta: {$c['cvepago']}, Año: {$c['ejercicio']}\n";
        echo "   Total descuentos: {$c['total_descuentos']}\n";
        echo "   Suma valores: {$c['suma_valores']}%\n\n";
    }

    // Obtener detalles de los 3 mejores ejemplos
    echo "\n=== DETALLES DE LOS 3 MEJORES EJEMPLOS ===\n\n";

    for ($i = 0; $i < min(3, count($cuentas)); $i++) {
        $cuenta = $cuentas[$i];
        $num = $i + 1;
        
        echo "EJEMPLO $num: Cuenta {$cuenta['cvepago']}, Año {$cuenta['ejercicio']}\n";
        echo str_repeat("=", 60) . "\n\n";
        
        $sqlDetalle = "
            SELECT
                d.id_multa,
                m.num_acta as folio,
                m.axo_acta as anio,
                m.contribuyente,
                m.domicilio,
                m.total as monto_multa,
                d.tipo_descto,
                d.valor as porcentaje_descto,
                (m.total * d.valor / 100) as importe_descto,
                d.feccap as fecha_captura,
                d.capturista,
                d.observacion,
                d.autoriza,
                d.estado
            FROM comun.h_descmultampal d
            INNER JOIN comun.multas m ON d.id_multa = m.id_multa
            WHERE d.cvepago = {$cuenta['cvepago']}
            AND EXTRACT(YEAR FROM m.fecha_acta) = {$cuenta['ejercicio']}
            ORDER BY d.feccap
            LIMIT 10
        ";
        
        $stmt = $pdo->query($sqlDetalle);
        $detalles = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo "Total de descuentos: " . count($detalles) . "\n\n";
        
        foreach ($detalles as $j => $det) {
            $subnum = $j + 1;
            echo "  $subnum. Folio: {$det['folio']}, Año: {$det['anio']}\n";
            echo "     Contribuyente: {$det['contribuyente']}\n";
            echo "     Domicilio: {$det['domicilio']}\n";
            echo "     Monto Multa: \${$det['monto_multa']}\n";
            echo "     Descuento: {$det['porcentaje_descto']}% = \$" . number_format($det['importe_descto'], 2) . "\n";
            echo "     Fecha Captura: {$det['fecha_captura']}\n";
            echo "     Capturista: {$det['capturista']}\n";
            echo "     Autoriza: {$det['autoriza']}\n";
            echo "     Estado: {$det['estado']}\n";
            echo "     Observación: {$det['observacion']}\n";
            echo "\n";
        }
        
        echo "\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
