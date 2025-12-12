<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Todas las multas (sin filtro)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: ID=".$r["id_multa"]." Folio=".$r["folio"]." ".$r["contribuyente"]." Total=$".number_format($r["total"],2)."\n\n";
}

echo "Prueba 2: Buscar por contribuyente MARIA\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm(?)");
$stmt->execute(["MARIA"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Contribuyente: ".$r["contribuyente"]." Giro: ".$r["giro"]." Total: $".number_format($r["total"],2)."\n\n";
}

echo "Prueba 3: Buscar por giro RESTAURANTE\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multasfrm(?)");
$stmt->execute(["RESTAURANTE"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Giro: ".$r["giro"]." Domicilio: ".$r["domicilio"]." Estatus: ".$r["estatus"]."\n\n";
}

echo "✅ Todas las pruebas completadas!\n";
