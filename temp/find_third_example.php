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

    echo "=== BUSCANDO MÁS EJEMPLOS ===\n\n";

    // Buscar diferentes cuentas con descuentos
    $sql = "
        SELECT
            d.cvepago,
            EXTRACT(YEAR FROM m.fecha_acta) as ejercicio,
            COUNT(*) as total_descuentos
        FROM comun.h_descmultampal d
        INNER JOIN comun.multas m ON d.id_multa = m.id_multa
        WHERE d.cvepago IS NOT NULL
        AND m.fecha_acta IS NOT NULL
        AND d.cvepago NOT IN (7569004, 9252925)
        GROUP BY d.cvepago, EXTRACT(YEAR FROM m.fecha_acta)
        HAVING COUNT(*) >= 2
        ORDER BY COUNT(*) DESC
        LIMIT 10
    ";

    $stmt = $pdo->query($sql);
    $cuentas = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($cuentas as $i => $c) {
        $num = $i + 1;
        echo "$num. Cuenta: {$c['cvepago']}, Año: {$c['ejercicio']}, Total: {$c['total_descuentos']}\n";
        
        // Obtener detalle del primero
        if ($i === 0) {
            echo "\nDETALLE EJEMPLO 3:\n";
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
                WHERE d.cvepago = {$c['cvepago']}
                AND EXTRACT(YEAR FROM m.fecha_acta) = {$c['ejercicio']}
                ORDER BY d.feccap
                LIMIT 10
            ";
            
            $stmt2 = $pdo->query($sqlDetalle);
            $detalles = $stmt2->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($detalles as $j => $det) {
                $subnum = $j + 1;
                echo "$subnum. Folio: {$det['folio']}, Año: {$det['anio']}\n";
                echo "   Contribuyente: {$det['contribuyente']}\n";
                echo "   Monto Multa: \${$det['monto_multa']}\n";
                echo "   Descuento: {$det['porcentaje_descto']}% = \$" . number_format($det['importe_descto'], 2) . "\n";
                echo "   Estado: {$det['estado']}\n\n";
            }
        }
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
