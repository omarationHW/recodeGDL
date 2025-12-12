<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Buscar por cuenta 260676 (ejemplo del placeholder)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_propuestatab(?)");
$stmt->execute(["260676"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." propuesta(s)\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  CvePago: ".$r["cvepago"]." Cuenta: ".$r["cvecuenta"]." Folio: ".$r["folio"]."\n";
    echo "  Recaud: ".$r["recaud"]." Caja: ".$r["caja"]." Importe: $".number_format($r["importe"],2)."\n";
    echo "  Fecha: ".$r["fecha"]." Hora: ".$r["hora"]." Cajero: ".$r["cajero"]."\n";
    echo "  Concepto: ".$r["cveconcepto"]." Estado: ".$r["estado"]."\n\n";
}

echo "Prueba 2: Buscar por folio 6334905 (ejemplo del placeholder)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_propuestatab(?)");
$stmt->execute(["6334905"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." propuesta(s)\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Folio: ".$r["folio"]." Cuenta: ".$r["cvecuenta"]." Cajero: ".$r["cajero"]."\n";
    echo "  Estado: ".$r["estado"]." Importe: $".number_format($r["importe"],2)."\n\n";
}

echo "Prueba 3: Buscar por cajero ODOO (ejemplo del placeholder)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_propuestatab(?)");
$stmt->execute(["ODOO"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." propuesta(s)\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Cajero: ".$r["cajero"]." Caja: ".$r["caja"]." Recaud: ".$r["recaud"]."\n";
    echo "  Importe: $".number_format($r["importe"],2)." Estado: ".$r["estado"]."\n\n";
}

echo "Prueba 4: Todas las propuestas (sin filtro)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_propuestatab('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Total de propuestas: ".count($rows)."\n";

// Estadísticas por estado
$por_estado = [];
$total_importe = 0;
foreach($rows as $r) {
    $estado = $r["estado"];
    if(!isset($por_estado[$estado])) $por_estado[$estado] = ['count' => 0, 'importe' => 0];
    $por_estado[$estado]['count']++;
    $por_estado[$estado]['importe'] += $r["importe"];
    $total_importe += $r["importe"];
}

echo "  Distribución por estado:\n";
foreach($por_estado as $estado => $data) {
    echo "    - $estado: ".$data['count']." propuestas ($".number_format($data['importe'],2).")\n";
}
echo "  Total general: $".number_format($total_importe,2)."\n\n";

echo "Prueba 5: Buscar por recaudadora MULTAS\n";
$stmt = $pdo->prepare("SELECT * FROM publico.propuestas_pago WHERE recaud = 'MULTAS' LIMIT 5");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Primeras 5 propuestas de MULTAS:\n";
foreach($rows as $r) {
    echo "    - Folio: ".$r["folio"]." Importe: $".number_format($r["importe"],2)." Estado: ".$r["estado"]."\n";
}
echo "\n";

echo "✅ Todas las pruebas completadas!\n";
