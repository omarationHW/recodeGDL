<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Presupuesto del ejercicio 2014 (valor por defecto en la app)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres('2014')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros del ejercicio 2014\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Ejercicio=".$r["ejercicio"]." Título=".$r["titulo"]." Capítulo=".$r["capitulo"]."\n";
    echo "  Cuenta: ".$r["cta_aplicacion"]." Presup Anual: $".number_format($r["presup_anual"],2)."\n";
    echo "  Ingreso Total: $".number_format($r["ingreso_total"],2)."\n";
    echo "  Enero: $".number_format($r["enero"],2)." Febrero: $".number_format($r["febrero"],2);
    echo " Marzo: $".number_format($r["marzo"],2)."\n";

    // Calcular totales
    $total_presup = array_sum(array_column($rows, 'presup_anual'));
    $total_ingreso = array_sum(array_column($rows, 'ingreso_total'));
    echo "  TOTALES 2014: Presup Anual=$".number_format($total_presup,2)." Ingreso Total=$".number_format($total_ingreso,2)."\n\n";
}

echo "Prueba 2: Presupuesto del ejercicio 2013\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres('2013')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros del ejercicio 2013\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Primera cuenta: ".$r["cta_aplicacion"]." - ".$r["titulo"]." (".$r["capitulo"].")\n";
    echo "  Ingreso Total: $".number_format($r["ingreso_total"],2)."\n\n";
}

echo "Prueba 3: Presupuesto del ejercicio 2012\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres('2012')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros del ejercicio 2012\n";
if(count($rows)>0) {
    echo "  Primeros 3 títulos encontrados:\n";
    $shown = [];
    foreach($rows as $r) {
        if(!in_array($r["titulo"], $shown) && count($shown) < 3) {
            echo "    - ".$r["titulo"]." (".$r["capitulo"].") = $".number_format($r["ingreso_total"],2)."\n";
            $shown[] = $r["titulo"];
        }
    }
    echo "\n";
}

echo "Prueba 4: Todos los registros (sin filtro)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_pres('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Total de registros en la tabla: ".count($rows)."\n";

// Contar por ejercicio
$por_ejercicio = [];
foreach($rows as $r) {
    $ej = $r["ejercicio"];
    if(!isset($por_ejercicio[$ej])) $por_ejercicio[$ej] = 0;
    $por_ejercicio[$ej]++;
}
echo "  Distribución por ejercicio:\n";
foreach($por_ejercicio as $ej => $cnt) {
    echo "    - Ejercicio $ej: $cnt registros\n";
}
echo "\n";

echo "✅ Todas las pruebas completadas!\n";
