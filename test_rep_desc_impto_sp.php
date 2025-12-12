<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS DE REPORTE DESCUENTO IMPUESTO ===\n\n";

// Prueba 1: Ejercicio 2025
echo "Prueba 1: Reporte del ejercicio 2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias\n";
if (count($rows) > 0) {
    $total_multas = 0;
    $total_general = 0;
    foreach ($rows as $r) {
        echo "  - Dep {$r['dependencia']}: {$r['nombre_dependencia']}\n";
        echo "    Multas: " . number_format($r['cantidad_multas']) . " | Total: $" . number_format($r['total_general'], 2) . "\n";
        $total_multas += $r['cantidad_multas'];
        $total_general += $r['total_general'];
    }
    echo "\n  TOTALES EJERCICIO 2025:\n";
    echo "    Cantidad: " . number_format($total_multas) . " multas\n";
    echo "    Recaudado: $" . number_format($total_general, 2) . "\n\n";
}

// Prueba 2: Ejercicio 2024
echo "Prueba 2: Reporte del ejercicio 2024\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2024)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias\n";
if (count($rows) > 0) {
    $total_multas = 0;
    $total_general = 0;
    foreach ($rows as $r) {
        echo "  - Dep {$r['dependencia']}: {$r['nombre_dependencia']}\n";
        echo "    Multas: " . number_format($r['cantidad_multas']) . " | Total: $" . number_format($r['total_general'], 2) . "\n";
        $total_multas += $r['cantidad_multas'];
        $total_general += $r['total_general'];
    }
    echo "\n  TOTALES EJERCICIO 2024:\n";
    echo "    Cantidad: " . number_format($total_multas) . " multas\n";
    echo "    Recaudado: $" . number_format($total_general, 2) . "\n\n";
}

// Prueba 3: Ejercicio sin datos (2023)
echo "Prueba 3: Ejercicio sin datos (2023)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2023)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias\n";
if (count($rows) == 0) {
    echo "  ✅ Correcto: No hay datos para 2023\n\n";
}

// Comparación de ejercicios
echo "Comparación de Ejercicios 2024 vs 2025:\n";

$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2024)");
$stmt->execute();
$data_2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total_2024_multas = array_sum(array_column($data_2024, 'cantidad_multas'));
$total_2024_general = array_sum(array_column($data_2024, 'total_general'));

$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2025)");
$stmt->execute();
$data_2025 = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total_2025_multas = array_sum(array_column($data_2025, 'cantidad_multas'));
$total_2025_general = array_sum(array_column($data_2025, 'total_general'));

echo "\n  EJERCICIO 2024:\n";
echo "    Multas: " . number_format($total_2024_multas) . "\n";
echo "    Total: $" . number_format($total_2024_general, 2) . "\n";

echo "\n  EJERCICIO 2025:\n";
echo "    Multas: " . number_format($total_2025_multas) . "\n";
echo "    Total: $" . number_format($total_2025_general, 2) . "\n";

$dif_multas = $total_2025_multas - $total_2024_multas;
$dif_general = $total_2025_general - $total_2024_general;
$pct_multas = ($dif_multas / $total_2024_multas) * 100;
$pct_general = ($dif_general / $total_2024_general) * 100;

echo "\n  VARIACIÓN:\n";
echo "    Multas: " . ($dif_multas >= 0 ? '+' : '') . number_format($dif_multas) . " (" . number_format($pct_multas, 2) . "%)\n";
echo "    Total: " . ($dif_general >= 0 ? '+$' : '-$') . number_format(abs($dif_general), 2) . " (" . number_format($pct_general, 2) . "%)\n";

// Desglose por dependencia 2025
echo "\n\nDesglose detallado por dependencia (Ejercicio 2025):\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($rows as $r) {
    $promedio = $r['total_multas'] / $r['cantidad_multas'];
    $porcentaje_gastos = ($r['total_gastos'] / $r['total_multas']) * 100;

    echo "\n  {$r['nombre_dependencia']} (Dep {$r['dependencia']}):\n";
    echo "    - Cantidad: " . number_format($r['cantidad_multas']) . " multas\n";
    echo "    - Total multas: $" . number_format($r['total_multas'], 2) . "\n";
    echo "    - Total gastos: $" . number_format($r['total_gastos'], 2) . " (" . number_format($porcentaje_gastos, 1) . "%)\n";
    echo "    - Total general: $" . number_format($r['total_general'], 2) . "\n";
    echo "    - Promedio por multa: $" . number_format($promedio, 2) . "\n";
}

// Top 3 dependencias por recaudación 2025
echo "\n\nTop 3 dependencias por recaudación (2025):\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_rep_desc_impto(2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
usort($rows, fn($a, $b) => $b['total_general'] - $a['total_general']);

for ($i = 0; $i < min(3, count($rows)); $i++) {
    $r = $rows[$i];
    $num = $i + 1;
    echo "  {$num}. {$r['nombre_dependencia']}: $" . number_format($r['total_general'], 2) . " ({$r['cantidad_multas']} multas)\n";
}

echo "\n✅ Todas las pruebas completadas!\n";
