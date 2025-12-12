<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Todos los descuentos del año 2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto('', 2025, 0, 10)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." de ".$rows[0]['total_registros']." total\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Folio=".$r["folio"]." ".$r["contribuyente"]." Tipo=".$r["tipo_descto"];
    echo " Descto: ".$r["porcentaje_descto"]."% = $".number_format($r["importe_descto"],2)."\n\n";
}

echo "Prueba 2: Buscar por cuenta CTA-DESC-000010\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto(?, 0, 0, 10)");
$stmt->execute(["CTA-DESC-000010"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total = count($rows) > 0 ? $rows[0]['total_registros'] : 0;
echo "  Resultados: ".count($rows)." de ".$total." total\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Cuenta: ".$r["clave_cuenta"]." Multa: $".number_format($r["monto_multa"],2);
    echo " Autoriza: ".$r["autoriza"]." Estado: ".$r["estado"]."\n\n";
}

echo "Prueba 3: Todos los descuentos del año 2024\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_otorga_descto('', 2024, 0, 10)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total = count($rows) > 0 ? $rows[0]['total_registros'] : 0;
echo "  Resultados: ".count($rows)." de ".$total." total del 2024\n\n";

echo "✅ Todas las pruebas completadas!\n";
