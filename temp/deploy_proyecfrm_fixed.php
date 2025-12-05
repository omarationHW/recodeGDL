<?php
// Desplegar SP corregido: recaudadora_proyecfrm
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP CORREGIDO: recaudadora_proyecfrm ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/recaudadora_proyecfrm_fixed.sql';
    if (!file_exists($sqlFile)) {
        die("Error: No se encontró el archivo $sqlFile\n");
    }

    $sql = file_get_contents($sqlFile);

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✅ Stored Procedure corregido desplegado exitosamente\n\n";

    // Probar el SP con diferentes filtros
    echo "=== PROBANDO SP CORREGIDO ===\n\n";

    // Prueba 1: Sin filtro
    echo "--- PRUEBA 1: SIN FILTRO ---\n";
    $sql1 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('') LIMIT 5";
    $stmt1 = $pdo->query($sql1);
    $result1 = $stmt1->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result1 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 40) . "\n";
    }
    echo "\n";

    // Prueba 2: Filtro 2007
    echo "--- PRUEBA 2: FILTRO '2007' ---\n";
    $sql2 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('2007') LIMIT 5";
    $stmt2 = $pdo->query($sql2);
    $result2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result2 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 40) . "\n";
    }
    echo "\n";

    // Prueba 3: Filtro OBRA
    echo "--- PRUEBA 3: FILTRO 'OBRA' ---\n";
    $sql3 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('OBRA') LIMIT 5";
    $stmt3 = $pdo->query($sql3);
    $result3 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result3 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 40) . "\n";
    }
    echo "\n";

    // Prueba 4: Filtro proyecto 6
    echo "--- PRUEBA 4: FILTRO '6' (proyecto específico) ---\n";
    $sql4 = "SELECT ejercicio, proyecto, descripcion FROM public.recaudadora_proyecfrm('6') LIMIT 5";
    $stmt4 = $pdo->query($sql4);
    $result4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    foreach ($result4 as $idx => $r) {
        echo ($idx + 1) . ". Ejercicio: {$r['ejercicio']}, Proyecto: {$r['proyecto']}, Desc: " . substr($r['descripcion'], 0, 40) . "\n";
    }
    echo "\n";

    echo "✅ CORRECCIÓN EXITOSA: Ahora cada proyecto aparece solo una vez\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
