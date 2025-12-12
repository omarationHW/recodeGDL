<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
echo "Prueba 1: Todas las multas\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas\n\n";

echo "Prueba 2: Buscar por MARIA\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm(?)");
$stmt->execute(["MARIA"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: ID=".$r["id_multa"]." Acta=".$r["num_acta"]." ".$r["contribuyente"]." Total=$".number_format($r["total"],2)."\n\n";
}

echo "Prueba 3: Buscar por SEAPAL\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas400frm(?)");
$stmt->execute(["SEAPAL"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas\n\n";

echo "✅ Todas las pruebas completadas!\n";
