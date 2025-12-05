<?php
// Debug: Verificar filtros del SP recaudadora_proyecfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DEBUG: VERIFICANDO FILTROS DEL SP ===\n\n";

    // PRUEBA 1: Sin filtro (vacío)
    echo "--- PRUEBA 1: SIN FILTRO (vacío) ---\n";
    $sql1 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('') LIMIT 5";
    $stmt1 = $pdo->query($sql1);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    echo "Primeros 5 registros:\n";
    foreach ($result1 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 50) . "\n";
    }
    echo "\n";

    // PRUEBA 2: Filtro por ejercicio 2007
    echo "--- PRUEBA 2: FILTRO '2007' ---\n";
    $sql2 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('2007') LIMIT 5";
    $stmt2 = $pdo->query($sql2);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Primeros 5 registros:\n";
    foreach ($result2 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 50) . "\n";
    }
    echo "\n";

    // PRUEBA 3: Filtro por texto 'OBRA'
    echo "--- PRUEBA 3: FILTRO 'OBRA' ---\n";
    $sql3 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('OBRA') LIMIT 5";
    $stmt3 = $pdo->query($sql3);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    echo "Primeros 5 registros:\n";
    foreach ($result3 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 50) . "\n";
    }
    echo "\n";

    // Verificar cuántos ejercicios diferentes hay
    echo "--- VERIFICANDO EJERCICIOS DISPONIBLES ---\n";
    $sqlEj = "SELECT DISTINCT ejercicio FROM comun.ta_proyectos ORDER BY ejercicio DESC LIMIT 10";
    $stmtEj = $pdo->query($sqlEj);
    $ejercicios = $stmtEj->fetchAll(PDO::FETCH_COLUMN);
    echo "Ejercicios disponibles: " . implode(", ", $ejercicios) . "\n\n";

    // Verificar cuántos proyectos hay por ejercicio
    echo "--- CONTEO DE PROYECTOS POR EJERCICIO ---\n";
    $sqlCount = "
        SELECT ejercicio, COUNT(*) as total
        FROM comun.ta_proyectos
        GROUP BY ejercicio
        ORDER BY ejercicio DESC
        LIMIT 10
    ";
    $stmtCount = $pdo->query($sqlCount);
    $counts = $stmtCount->fetchAll(PDO::FETCH_ASSOC);

    foreach ($counts as $c) {
        echo "Ejercicio {$c['ejercicio']}: {$c['total']} proyectos\n";
    }
    echo "\n";

    // Verificar si hay proyectos con diferentes ejercicios en los primeros 50
    echo "--- EJERCICIOS EN LOS PRIMEROS 50 REGISTROS (sin filtro) ---\n";
    $sql50 = "
        SELECT DISTINCT ejercicio
        FROM comun.ta_proyectos
        ORDER BY ejercicio DESC, proyecto ASC
        LIMIT 50
    ";
    $stmt50 = $pdo->query($sql50);
    $ej50 = $stmt50->fetchAll(PDO::FETCH_COLUMN);
    echo "Ejercicios únicos en primeros 50: " . implode(", ", $ej50) . "\n\n";

    // Probar con un proyecto específico
    echo "--- PRUEBA 4: FILTRO POR PROYECTO '4' ---\n";
    $sql4 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('4') LIMIT 5";
    $stmt4 = $pdo->query($sql4);
    $result4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    echo "Registros encontrados: " . count($result4) . "\n";
    foreach ($result4 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 50) . "\n";
    }
    echo "\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
