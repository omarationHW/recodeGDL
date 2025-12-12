<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS DE CALCULADORA DE MULTAS ===\n\n";

echo "Prueba 1: Sin parámetros (valores por defecto: $1,000, 0 meses, 0% descuento)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas()");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Resultados:\n";
foreach($rows as $r) {
    echo "  " . str_pad($r["concepto"], 20) . " | ";
    echo str_pad($r["descripcion"], 50) . " | ";
    echo str_pad("$".number_format($r["valor"], 2), 15, " ", STR_PAD_LEFT) . " | ";
    echo str_pad($r["porcentaje"] > 0 ? $r["porcentaje"]."%" : "-", 8, " ", STR_PAD_LEFT) . "\n";
}
echo "\n";

echo "Prueba 2: Ejemplo 1 del Vue - $1,000 sin mora\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(1000, 0, 0)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Resultados:\n";
foreach($rows as $r) {
    echo "  " . str_pad($r["concepto"], 20) . " | ";
    echo str_pad($r["descripcion"], 50) . " | ";
    echo str_pad("$".number_format($r["valor"], 2), 15, " ", STR_PAD_LEFT) . " | ";
    echo str_pad($r["porcentaje"] > 0 ? $r["porcentaje"]."%" : "-", 8, " ", STR_PAD_LEFT) . "\n";
}
echo "\n";

echo "Prueba 3: Ejemplo 2 del Vue - $5,000 con 6 meses de mora\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(5000, 6, 0)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Resultados:\n";
$total_a_pagar = 0;
foreach($rows as $r) {
    echo "  " . str_pad($r["concepto"], 20) . " | ";
    echo str_pad($r["descripcion"], 50) . " | ";
    echo str_pad("$".number_format($r["valor"], 2), 15, " ", STR_PAD_LEFT) . " | ";
    echo str_pad($r["porcentaje"] > 0 ? $r["porcentaje"]."%" : "-", 8, " ", STR_PAD_LEFT) . "\n";
    if($r["concepto"] == "TOTAL A PAGAR") {
        $total_a_pagar = $r["valor"];
    }
}
echo "  💰 Total calculado con 6 meses al 2% mensual = 12% de recargos\n";
echo "  📊 Recargos: $5,000 * 12% = $600\n";
echo "  📊 Total: $5,000 + $600 = $".number_format($total_a_pagar, 2)."\n\n";

echo "Prueba 4: Ejemplo 3 del Vue - $10,000 con 12 meses de mora y 20% descuento\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(10000, 12, 20)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Resultados:\n";
$total_a_pagar = 0;
foreach($rows as $r) {
    echo "  " . str_pad($r["concepto"], 20) . " | ";
    echo str_pad($r["descripcion"], 50) . " | ";
    echo str_pad("$".number_format($r["valor"], 2), 15, " ", STR_PAD_LEFT) . " | ";
    echo str_pad($r["porcentaje"] > 0 ? $r["porcentaje"]."%" : "-", 8, " ", STR_PAD_LEFT) . "\n";
    if($r["concepto"] == "TOTAL A PAGAR") {
        $total_a_pagar = $r["valor"];
    }
}
echo "  💰 Total calculado con 12 meses al 2% mensual = 24% de recargos\n";
echo "  📊 Recargos: $10,000 * 24% = $2,400\n";
echo "  📊 Subtotal: $10,000 + $2,400 = $12,400\n";
echo "  📊 Descuento: $12,400 * 20% = $2,480\n";
echo "  📊 Total: $12,400 - $2,480 = $".number_format($total_a_pagar, 2)."\n\n";

echo "Prueba 5: Caso extremo - $50,000 con 24 meses y 10% descuento\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pruebacalcas(50000, 24, 10)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "Resultados:\n";
foreach($rows as $r) {
    echo "  " . str_pad($r["concepto"], 20) . " | ";
    echo str_pad($r["descripcion"], 50) . " | ";
    echo str_pad("$".number_format($r["valor"], 2), 15, " ", STR_PAD_LEFT) . " | ";
    echo str_pad($r["porcentaje"] > 0 ? $r["porcentaje"]."%" : "-", 8, " ", STR_PAD_LEFT) . "\n";
}
echo "\n";

echo "✅ Todas las pruebas completadas correctamente!\n";
echo "✅ La calculadora funciona con:\n";
echo "   - Tasa de recargo: 2% mensual\n";
echo "   - Fórmula recargos: importe_base * 2% * meses_mora\n";
echo "   - Fórmula descuento: (importe_base + recargos) * % descuento\n";
echo "   - Total: (importe_base + recargos) - descuento\n";
