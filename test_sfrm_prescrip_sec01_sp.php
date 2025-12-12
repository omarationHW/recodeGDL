<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "Prueba 1: Buscar prescripciones sin filtro (últimos registros)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sfrm_prescrip_sec01('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." prescripciones\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Primera: ID=".$r["id_prescri"]." Oficio=".$r["oficio"]." ID Multa=".$r["id_multa"]."\n";
    echo "  Fecha Aut: ".$r["fecaut"]." Fecha Prescr: ".$r["fecha_prescri"]."\n";
    echo "  Dependencia: ".$r["dependencia"]." Capturista: ".$r["capturista"]."\n\n";
}

echo "Prueba 2: Buscar por dependencia DIRECCIÓN\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sfrm_prescrip_sec01(?)");
$stmt->execute(["DIRECCIÓN"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." prescripciones encontradas\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Dependencia=".$r["dependencia"]." Oficio=".$r["oficio"]."\n";
    echo "  ID Multa: ".$r["id_multa"]." Capturista: ".$r["capturista"]."\n\n";
}

echo "Prueba 3: Buscar por capturista MARTINEZ\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sfrm_prescrip_sec01(?)");
$stmt->execute(["MARTINEZ"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." prescripciones\n";
if(count($rows)>0) {
    echo "  Primeros 3 resultados:\n";
    for($i=0; $i<min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - ID Prescr: ".$r["id_prescri"]." Multa: ".$r["id_multa"];
        echo " Capturista: ".$r["capturista"]."\n";
    }
    echo "\n";
}

echo "Prueba 4: Buscar por patrón de oficio PRESC/2025\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_sfrm_prescrip_sec01(?)");
$stmt->execute(["PRESC/2025"]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." prescripciones del 2025\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Ejemplo: Oficio=".$r["oficio"]." Fecha Aut=".$r["fecaut"]."\n";
    echo "  Observaciones: ".($r["observaciones"] ?: "N/A")."\n\n";
}

// Estadísticas generales
echo "Estadísticas generales:\n";
$stmt = $pdo->prepare("SELECT COUNT(*) as total,
    COUNT(CASE WHEN observaciones != '' THEN 1 END) as con_obs,
    MIN(fecha_prescri) as fecha_min,
    MAX(fecaut) as fecha_max
FROM catastro_gdl.presc_multas");
$stmt->execute();
$stats = $stmt->fetch(PDO::FETCH_ASSOC);
echo "  Total de prescripciones: ".$stats["total"]."\n";
echo "  Con observaciones: ".$stats["con_obs"]."\n";
echo "  Fecha prescripción más antigua: ".$stats["fecha_min"]."\n";
echo "  Fecha autorización más reciente: ".$stats["fecha_max"]."\n\n";

echo "✅ Todas las pruebas completadas!\n";
