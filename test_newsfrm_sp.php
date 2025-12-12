<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Todas las novedades (primera página, 10 registros)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm('', 0, 10)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas de ".$rows[0]['total_registros']." total\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: ID=".$r["id_multa"]." Folio=".$r["folio"]." ".$r["contribuyente"];
    echo " Estatus: ".$r["estatus"]." Total=$".number_format($r["total"],2)."\n\n";
}

echo "Prueba 2: Buscar por contribuyente MARIA\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm(?, 0, 10)");
$stmt->execute(["MARIA"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total = count($rows) > 0 ? $rows[0]['total_registros'] : 0;
echo "  Resultados: ".count($rows)." de ".$total." total\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Contribuyente: ".$r["contribuyente"]." Folio: ".$r["folio"]." Estatus: ".$r["estatus"]."\n\n";
}

echo "Prueba 3: Buscar por año 2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_newsfrm(?, 0, 10)");
$stmt->execute(["2025"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total = count($rows) > 0 ? $rows[0]['total_registros'] : 0;
echo "  Resultados: ".count($rows)." de ".$total." total\n\n";

echo "✅ Todas las pruebas completadas!\n";
