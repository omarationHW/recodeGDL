<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Todas las pólizas del año 2012 (fecha por defecto en la app)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon('2012-01-01', '2012-12-31')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." cuentas consolidadas\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Cuenta=".$r["cvectaapl"]." ".$r["ctaaplicacion"];
    echo " Partidas: ".$r["totpar"]." Suma: $".number_format($r["suma"],2)." Movs: ".$r["num_movimientos"]."\n";

    // Calcular totales
    $total_partidas = array_sum(array_column($rows, 'totpar'));
    $total_suma = array_sum(array_column($rows, 'suma'));
    $total_movs = array_sum(array_column($rows, 'num_movimientos'));
    echo "  TOTALES: Partidas=$total_partidas Suma=$".number_format($total_suma,2)." Movimientos=$total_movs\n\n";
}

echo "Prueba 2: Pólizas del primer trimestre de 2012\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon('2012-01-01', '2012-03-31')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." cuentas consolidadas del Q1 2012\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Primera cuenta: ".$r["cvectaapl"]." - ".$r["ctaaplicacion"];
    echo " Total: $".number_format($r["suma"],2)."\n\n";
}

echo "Prueba 3: Pólizas de un mes específico (Julio 2012)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_polcon('2012-07-01', '2012-07-31')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." cuentas consolidadas de Julio 2012\n";
if(count($rows)>0) {
    echo "  Cuentas encontradas:\n";
    foreach($rows as $r) {
        echo "    - ".$r["cvectaapl"]." (".$r["ctaaplicacion"].") = $".number_format($r["suma"],2)."\n";
    }
    echo "\n";
}

echo "✅ Todas las pruebas completadas!\n";
