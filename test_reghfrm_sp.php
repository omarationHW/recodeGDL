<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS DE REGISTRO HISTÓRICO ===\n\n";

// Prueba 1: Buscar por ID específico
echo "Prueba 1: Buscar por ID multa 415010\n";
$filtros = json_encode([
    'tipo' => 'id',
    'id_multa' => 415010,
    'limite' => 10
]);
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
$stmt->execute([$filtros]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registro(s)\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  ID: ".$r["id_multa"]." Dep: ".$r["id_dependencia"]." Acta: ".$r["axo_acta"]."/".$r["num_acta"]."\n";
    echo "  Contribuyente: ".$r["contribuyente"]."\n";
    echo "  Calificación: $".number_format($r["calificacion"],2)."\n\n";
}

// Prueba 2: Buscar por dependencia 3 (Tránsito)
echo "Prueba 2: Buscar por dependencia 3 (Tránsito)\n";
$filtros = json_encode([
    'tipo' => 'dependencia',
    'id_dependencia' => 3,
    'fecha_inicio' => '2024-01-01',
    'fecha_fin' => '2024-12-31',
    'limite' => 10
]);
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
$stmt->execute([$filtros]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros de Tránsito en 2024\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: ID=".$r["id_multa"]." Dep=".$r["id_dependencia"]." (".$r["contribuyente"].")\n\n";
}

// Prueba 3: Buscar por dependencia 7 (Reglamentos)
echo "Prueba 3: Buscar por dependencia 7 (Reglamentos) con licencias\n";
$filtros = json_encode([
    'tipo' => 'dependencia',
    'id_dependencia' => 7,
    'fecha_inicio' => '2025-01-01',
    'fecha_fin' => '2025-12-31',
    'limite' => 10
]);
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
$stmt->execute([$filtros]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros de Reglamentos en 2025\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: ID=".$r["id_multa"]." Licencia: ".$r["num_licencia"]." Giro: ".$r["giro"]."\n\n";
}

// Prueba 4: Buscar por rango de fechas últimos 30 días
$hoy = date('Y-m-d');
$hace30dias = date('Y-m-d', strtotime('-30 days'));
echo "Prueba 4: Buscar últimos 30 días ($hace30dias a $hoy)\n";
$filtros = json_encode([
    'tipo' => 'rango',
    'fecha_inicio' => $hace30dias,
    'fecha_fin' => $hoy,
    'limite' => 20
]);
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
$stmt->execute([$filtros]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros en últimos 30 días\n";
if(count($rows)>0) {
    echo "  Primeros 3 resultados:\n";
    for($i=0; $i<min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - ID ".$r["id_multa"]." Dep ".$r["id_dependencia"]." Fecha: ".$r["fecha_acta"]."\n";
    }
    echo "\n";
}

// Prueba 5: Filtrar por año de acta
echo "Prueba 5: Buscar por año de acta 2025\n";
$filtros = json_encode([
    'tipo' => 'rango',
    'axo_acta' => 2025,
    'fecha_inicio' => '2025-01-01',
    'fecha_fin' => '2025-12-31',
    'limite' => 15
]);
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_reghfrm(?)");
$stmt->execute([$filtros]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." registros del año 2025\n\n";

// Estadísticas generales
echo "Estadísticas generales:\n";
$stmt = $pdo->prepare("
    SELECT
        id_dependencia,
        axo_acta,
        COUNT(*) as cantidad,
        ROUND(AVG(calificacion), 2) as calificacion_promedio
    FROM publico.registro_historico
    GROUP BY id_dependencia, axo_acta
    ORDER BY axo_acta DESC, id_dependencia
");
$stmt->execute();
$stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Distribución por dependencia y año:\n";
foreach($stats as $stat) {
    $dep_nombre = ($stat["id_dependencia"] == 3) ? "Tránsito" : "Reglamentos";
    echo "    - Dep ".$stat["id_dependencia"]." ($dep_nombre) ".$stat["axo_acta"].": ";
    echo $stat["cantidad"]." registros (Promedio: $".number_format($stat["calificacion_promedio"],2).")\n";
}

echo "\n✅ Todas las pruebas completadas!\n";
