<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Todas las multas del año 2025 (primera página)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm('', 2025, 0, 10)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." multas de ".$rows[0]['total_registros']." total\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Cuenta=".$r["clave_cuenta"]." Folio=".$r["folio"]." Ejercicio=".$r["ejercicio"]." Importe=$".number_format($r["importe"],2)."\n\n";
}

echo "Prueba 2: Todas las multas del año 2024\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm('', 2024, 0, 10)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total = count($rows) > 0 ? $rows[0]['total_registros'] : 0;
echo "  Resultados: ".count($rows)." de ".$total." total del 2024\n\n";

echo "Prueba 3: Buscar por cuenta CTA-DM-000010 (cualquier año)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_multas_dm(?, 0, 0, 10)");
$stmt->execute(["CTA-DM-000010"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total = count($rows) > 0 ? $rows[0]['total_registros'] : 0;
echo "  Resultados: ".count($rows)." multas de ".$total." total\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Cuenta: ".$r["clave_cuenta"]." Estatus: ".$r["estatus"]." Importe: $".number_format($r["importe"],2)."\n\n";
}

echo "✅ Todas las pruebas completadas!\n";
