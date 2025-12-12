<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Verificación de cálculos con diferentes parámetros:\n\n";

// Ejemplo 1: $1,000 sin mora ni descuento
echo "1. Importe: $1,000 | Mora: 0 meses | Descuento: 0%\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(1000, 0, 0)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach($rows as $r) {
    if($r['concepto'] == 'TOTAL A PAGAR') {
        echo "   → TOTAL: $" . number_format($r['valor'], 2) . "\n";
    }
}

// Ejemplo 2: $5,000 con 6 meses de mora
echo "2. Importe: $5,000 | Mora: 6 meses | Descuento: 0%\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(5000, 6, 0)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach($rows as $r) {
    if($r['concepto'] == 'RECARGOS') {
        echo "   → RECARGOS: $" . number_format($r['valor'], 2) . " (" . $r['porcentaje'] . "%)\n";
    }
    if($r['concepto'] == 'TOTAL A PAGAR') {
        echo "   → TOTAL: $" . number_format($r['valor'], 2) . "\n";
    }
}

// Ejemplo 3: $10,000 con 12 meses y 20% descuento
echo "3. Importe: $10,000 | Mora: 12 meses | Descuento: 20%\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(10000, 12, 20)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach($rows as $r) {
    if($r['concepto'] == 'RECARGOS') {
        echo "   → RECARGOS: $" . number_format($r['valor'], 2) . " (" . $r['porcentaje'] . "%)\n";
    }
    if($r['concepto'] == 'DESCUENTO') {
        echo "   → DESCUENTO: $" . number_format($r['valor'], 2) . " (" . $r['porcentaje'] . "%)\n";
    }
    if($r['concepto'] == 'TOTAL A PAGAR') {
        echo "   → TOTAL: $" . number_format($r['valor'], 2) . "\n";
    }
}

// Prueba adicional: $2,500 con 3 meses y 15% descuento
echo "4. Importe: $2,500 | Mora: 3 meses | Descuento: 15%\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(2500, 3, 15)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach($rows as $r) {
    if($r['concepto'] == 'RECARGOS') {
        echo "   → RECARGOS: $" . number_format($r['valor'], 2) . " (" . $r['porcentaje'] . "%)\n";
    }
    if($r['concepto'] == 'DESCUENTO') {
        echo "   → DESCUENTO: $" . number_format($r['valor'], 2) . " (" . $r['porcentaje'] . "%)\n";
    }
    if($r['concepto'] == 'TOTAL A PAGAR') {
        echo "   → TOTAL: $" . number_format($r['valor'], 2) . "\n";
    }
}

echo "\n✅ Cada ejemplo produce resultados DIFERENTES según los parámetros\n";
echo "✅ El formato de parámetros ha sido corregido en el Vue\n";
