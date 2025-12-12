<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== PRUEBAS DE EJECUTORES ADMINISTRATIVOS ===\n\n";

// Prueba 1: Todos los ejecutores (sin filtro)
echo "Prueba 1: Todos los ejecutores (sin filtro)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas('')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." ejecutores\n";
if(count($rows)>0) {
    $r = $rows[0];
    echo "  Primero: ID=".$r["id_ejecutor"]." Cve=".$r["cve_eje"]." ".$r["nombre"]."\n";
    echo "  RFC: ".$r["ini_rfc"]." Homoclave: ".$r["hom_rfc"]."\n";
    echo "  Recaudación: ".$r["id_rec"]." Categoría: ".$r["categoria"]." Vigencia: ".$r["vigencia"]."\n\n";
}

// Prueba 2: Buscar por nombre "JAVIER" (ejemplo del placeholder)
echo "Prueba 2: Buscar por nombre 'JAVIER'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas('JAVIER')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." ejecutores con 'JAVIER'\n";
if(count($rows)>0) {
    echo "  Primeros 3:\n";
    for($i=0; $i<min(3, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Cve ".$r["cve_eje"].": ".$r["nombre"]." (".$r["vigencia"].")\n";
    }
    echo "\n";
}

// Prueba 3: Buscar por clave (ej: "100", "154")
echo "Prueba 3: Buscar por clave '10'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas('10')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." ejecutores con clave que contiene '10'\n";
if(count($rows)>0) {
    echo "  Primeros 5:\n";
    for($i=0; $i<min(5, count($rows)); $i++) {
        $r = $rows[$i];
        echo "    - Cve ".$r["cve_eje"].": ".$r["nombre"]."\n";
    }
    echo "\n";
}

// Prueba 4: Buscar por RFC
echo "Prueba 4: Buscar por RFC (búsqueda parcial)\n";
$stmt = $pdo->prepare("SELECT * FROM publico.ejecutores_administrativos LIMIT 1");
$stmt->execute();
$ejemplo = $stmt->fetch(PDO::FETCH_ASSOC);
$rfc_busqueda = substr($ejemplo['ini_rfc'], 0, 4);
echo "  Buscando por RFC que contenga: '$rfc_busqueda'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas(?)");
$stmt->execute([$rfc_busqueda]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." ejecutores\n\n";

// Prueba 5: Filtrar por vigencia
echo "Prueba 5: Buscar ejecutores 'VIGENTE'\n";
$stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_regsecymas('VIGENTE')");
$stmt->execute();
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Resultados: ".count($rows)." ejecutores vigentes\n\n";

// Estadísticas generales
echo "Estadísticas generales:\n";
$stmt = $pdo->prepare("
    SELECT
        vigencia,
        COUNT(*) as cantidad,
        STRING_AGG(DISTINCT categoria, ', ') as categorias
    FROM publico.ejecutores_administrativos
    GROUP BY vigencia
    ORDER BY cantidad DESC
");
$stmt->execute();
$stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Distribución por vigencia:\n";
foreach($stats as $stat) {
    echo "    - ".$stat["vigencia"].": ".$stat["cantidad"]." ejecutores (Categorías: ".$stat["categorias"].")\n";
}

echo "\n";
$stmt = $pdo->prepare("
    SELECT
        categoria,
        COUNT(*) as cantidad
    FROM publico.ejecutores_administrativos
    GROUP BY categoria
    ORDER BY cantidad DESC
");
$stmt->execute();
$stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo "  Distribución por categoría:\n";
foreach($stats as $stat) {
    echo "    - ".$stat["categoria"].": ".$stat["cantidad"]." ejecutores\n";
}

echo "\n✅ Todas las pruebas completadas!\n";
