<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Buscar por clave de pago 260676 (ejemplo del placeholder)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_prepagofrm(?)");
$stmt->execute(["260676"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." pago(s)\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  CvePago: ".$r["cvepago"]." Cuenta: ".$r["cvecuenta"]." Folio: ".$r["folio"];
    echo " Importe: $".number_format($r["importe"],2)." Cancelado: ".$r["cancelado"]."\n";
    echo "  Fecha: ".$r["fecha_pago"]." Caja: ".$r["caja"]." Cajero: ".$r["cajero"]."\n\n";
}

echo "Prueba 2: Buscar por patrón de cuenta CTA-00\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_prepagofrm(?)");
$stmt->execute(["CTA-00"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." pago(s) encontrados\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Cuenta=".$r["cvecuenta"]." CvePago=".$r["cvepago"];
    echo " Importe=$".number_format($r["importe"],2)."\n";

    // Calcular total
    $total = array_sum(array_column($rows, 'importe'));
    echo "  Total de importes: $".number_format($total,2)."\n\n";
}

echo "Prueba 3: Buscar por folio F-001\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_prepagofrm(?)");
$stmt->execute(["F-001"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." pago(s)\n";
if(count($rows)>0) {
    echo "  Primeros 3 resultados:\n";
    for($i=0; $i<min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Folio: ".$r["folio"]." Importe: $".number_format($r["importe"],2);
        echo " Estado: ".$r["cancelado"]."\n";
    }
    echo "\n";
}

echo "Prueba 4: Buscar pagos cancelados\n";
$stmt = $pdo->prepare("SELECT * FROM publico.prepagos WHERE cancelado = 'Sí'");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Total de pagos cancelados: ".count($rows)."\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: CvePago=".$r["cvepago"]." Cuenta=".$r["cvecuenta"];
    echo " Importe=$".number_format($r["importe"],2)." Cancelado=".$r["cancelado"]."\n\n";
}

echo "✅ Todas las pruebas completadas!\n";
