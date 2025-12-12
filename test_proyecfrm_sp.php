<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Todos los proyectos (sin filtro)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." proyectos\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Primer proyecto: ".$r["nombre_proyecto"]."\n";
    echo "  Estado: ".$r["estado"]." Avance: ".$r["avance"]."%\n";
    echo "  Responsable: ".$r["responsable"]." Depto: ".$r["departamento"]."\n";
    echo "  Presupuesto: $".number_format($r["presupuesto"],2)."\n\n";
}

echo "Prueba 2: Buscar por estado 'EN CURSO'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm('EN CURSO')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." proyectos en curso\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: ".$r["nombre_proyecto"]." - Avance: ".$r["avance"]."%\n\n";
}

echo "Prueba 3: Buscar por departamento 'SISTEMAS'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm('SISTEMAS')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." proyectos de SISTEMAS\n";
if(count($rows)>0) {
    echo "  Primeros 3 proyectos:\n";
    for($i=0; $i<min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - ".$r["nombre_proyecto"]." (".$r["estado"].")\n";
    }
    echo "\n";
}

echo "Prueba 4: Buscar por responsable 'MARTINEZ'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_proyecfrm('MARTINEZ')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." proyectos\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Responsable: ".$r["responsable"]."\n";
    echo "  Proyecto: ".$r["nombre_proyecto"]."\n\n";
}

// Estadísticas generales
echo "Estadísticas generales:\n";
$stmt = $pdo->prepare("
    SELECT
        estado,
        COUNT(*) as cantidad,
        ROUND(AVG(avance), 0) as avance_promedio,
        SUM(presupuesto) as presupuesto_total
    FROM publico.proyectos
    GROUP BY estado
    ORDER BY cantidad DESC
");
$stmt->execute();
$stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Distribución por estado:\n";
$total_presupuesto = 0;
foreach($stats as $stat) {
    echo "    - ".$stat["estado"].": ".$stat["cantidad"]." proyectos";
    echo " (Avance promedio: ".$stat["avance_promedio"]."%)";
    echo " Presupuesto: $".number_format($stat["presupuesto_total"],2)."\n";
    $total_presupuesto += $stat["presupuesto_total"];
}
echo "  Total presupuesto general: $".number_format($total_presupuesto,2)."\n\n";

echo "✅ Todas las pruebas completadas!\n";
