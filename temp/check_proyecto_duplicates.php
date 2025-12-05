<?php
// Verificar duplicados en ta_proyecto_pres
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== VERIFICANDO DUPLICADOS ===\n\n";

    // Ver cuántos registros de presupuesto hay para el proyecto 4, ejercicio 2007
    $sql = "
        SELECT COUNT(*) as total
        FROM comun.ta_proyecto_pres
        WHERE ejercicio = 2007 AND proyecto = 4
    ";
    $stmt = $pdo->query($sql);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "Registros de presupuesto para Proyecto 4, Ejercicio 2007: {$result['total']}\n\n";

    // Ver los detalles
    $sql2 = "
        SELECT ejercicio, proyecto, dependencia, partida, programa
        FROM comun.ta_proyecto_pres
        WHERE ejercicio = 2007 AND proyecto = 4
        LIMIT 10
    ";
    $stmt2 = $pdo->query($sql2);
    $results = $stmt2->fetchAll(PDO::FETCH_ASSOC);

    echo "Primeros 10 registros de presupuesto:\n";
    foreach ($results as $idx => $r) {
        echo ($idx + 1) . ". Dep: {$r['dependencia']}, Part: {$r['partida']}, Prog: {$r['programa']}\n";
    }
    echo "\n";

    // Verificar cuántos proyectos únicos hay
    $sql3 = "
        SELECT COUNT(DISTINCT proyecto) as total
        FROM comun.ta_proyectos
        WHERE ejercicio = 2007
    ";
    $stmt3 = $pdo->query($sql3);
    $result3 = $stmt3->fetch(PDO::FETCH_ASSOC);
    echo "Proyectos únicos en ejercicio 2007: {$result3['total']}\n\n";

    // Listar proyectos únicos (primeros 20)
    $sql4 = "
        SELECT DISTINCT ejercicio, proyecto, descripcion
        FROM comun.ta_proyectos
        WHERE ejercicio = 2007
        ORDER BY proyecto
        LIMIT 20
    ";
    $stmt4 = $pdo->query($sql4);
    $results4 = $stmt4->fetchAll(PDO::FETCH_ASSOC);

    echo "Primeros 20 proyectos únicos del 2007:\n";
    foreach ($results4 as $idx => $r) {
        echo ($idx + 1) . ". Proyecto {$r['proyecto']}: " . substr($r['descripcion'], 0, 50) . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
