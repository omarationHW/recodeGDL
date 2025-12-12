<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS DE RELACIÓN MENSUAL ===\n\n";

// Prueba 1: Reporte anual 2025 (sin especificar mes)
echo "Prueba 1: Reporte anual completo 2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('', 2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias\n";
if (count($rows) > 0) {
    $total_multas = 0;
    $total_general = 0;
    foreach ($rows as $r) {
        echo "  - Dep {$r['dependencia']}: {$r['nombre_dependencia']}\n";
        echo "    Multas: {$r['cantidad_multas']} | Total: $" . number_format($r['total_general'], 2) . "\n";
        $total_multas += $r['cantidad_multas'];
        $total_general += $r['total_general'];
    }
    echo "  TOTALES: {$total_multas} multas | $" . number_format($total_general, 2) . "\n\n";
}

// Prueba 2: Reporte anual 2024
echo "Prueba 2: Reporte anual completo 2024\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('', 2024)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias\n";
if (count($rows) > 0) {
    $total_multas = 0;
    $total_general = 0;
    foreach ($rows as $r) {
        $total_multas += $r['cantidad_multas'];
        $total_general += $r['total_general'];
    }
    echo "  TOTALES: {$total_multas} multas | $" . number_format($total_general, 2) . "\n\n";
}

// Prueba 3: Reporte mensual - Enero 2025
echo "Prueba 3: Reporte de Enero 2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('1', 2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias en Enero\n";
if (count($rows) > 0) {
    foreach ($rows as $r) {
        echo "  - Dep {$r['dependencia']}: {$r['nombre_dependencia']}\n";
        echo "    Multas: {$r['cantidad_multas']} | Multas: $" . number_format($r['total_multas'], 2);
        echo " | Gastos: $" . number_format($r['total_gastos'], 2);
        echo " | Total: $" . number_format($r['total_general'], 2) . "\n";
    }
    echo "\n";
}

// Prueba 4: Reporte mensual - Julio 2025 (temporada alta)
echo "Prueba 4: Reporte de Julio 2025 (temporada alta)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('7', 2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias en Julio\n";
if (count($rows) > 0) {
    echo "  Top 3 dependencias con más multas:\n";
    usort($rows, fn($a, $b) => $b['cantidad_multas'] - $a['cantidad_multas']);
    for ($i = 0; $i < min(3, count($rows)); $i++) {
        $r = $rows[$i];
        $num = $i + 1;
        echo "    {$num}. Dep {$r['dependencia']} ({$r['nombre_dependencia']}): {$r['cantidad_multas']} multas\n";
    }
    echo "\n";
}

// Prueba 5: Reporte mensual - Diciembre 2024 (temporada alta)
echo "Prueba 5: Reporte de Diciembre 2024 (temporada alta)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('12', 2024)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: " . count($rows) . " dependencias en Diciembre 2024\n";
if (count($rows) > 0) {
    $total_mes = array_sum(array_column($rows, 'cantidad_multas'));
    echo "  Total multas en diciembre: {$total_mes}\n\n";
}

// Prueba 6: Comparar Febrero vs Agosto 2025
echo "Prueba 6: Comparación Febrero vs Agosto 2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('2', 2025)");
$stmt->execute();
$febrero = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total_feb = array_sum(array_column($febrero, 'cantidad_multas'));

$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('8', 2025)");
$stmt->execute();
$agosto = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total_ago = array_sum(array_column($agosto, 'cantidad_multas'));

echo "  Febrero 2025: {$total_feb} multas\n";
echo "  Agosto 2025: {$total_ago} multas\n";
$dif = $total_ago - $total_feb;
$pct = round(($dif / $total_feb) * 100, 1);
echo "  Diferencia: {$dif} multas ({$pct}% más en agosto)\n\n";

// Estadísticas por dependencia
echo "Estadísticas detalladas por dependencia (Año 2025):\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('', 2025)");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($rows as $r) {
    echo "\n  {$r['nombre_dependencia']} (Dep {$r['dependencia']}):\n";
    echo "    - Cantidad de multas: " . number_format($r['cantidad_multas']) . "\n";
    echo "    - Total multas: $" . number_format($r['total_multas'], 2) . "\n";
    echo "    - Total gastos: $" . number_format($r['total_gastos'], 2) . "\n";
    echo "    - Total general: $" . number_format($r['total_general'], 2) . "\n";

    $promedio = $r['total_multas'] / $r['cantidad_multas'];
    echo "    - Promedio por multa: $" . number_format($promedio, 2) . "\n";
}

// Comparación año a año
echo "\n\nComparación 2024 vs 2025:\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('', 2024)");
$stmt->execute();
$data_2024 = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total_2024 = array_sum(array_column($data_2024, 'total_general'));

$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_relmes('', 2025)");
$stmt->execute();
$data_2025 = $stmt->fetchAll(PDO::FETCH_ASSOC);
$total_2025 = array_sum(array_column($data_2025, 'total_general'));

echo "  Total 2024: $" . number_format($total_2024, 2) . "\n";
echo "  Total 2025: $" . number_format($total_2025, 2) . "\n";
$variacion = (($total_2025 - $total_2024) / $total_2024) * 100;
echo "  Variación: " . number_format($variacion, 2) . "%\n";

echo "\n✅ Todas las pruebas completadas!\n";
