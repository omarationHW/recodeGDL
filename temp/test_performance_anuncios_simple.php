<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST PERFORMANCE ANUNCIOS (SIMPLE)\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Test 1: Consulta directa a tabla con índices
    echo "========================================\n";
    echo "TEST 1: Consulta directa COUNT(*)\n";
    echo "========================================\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.anuncios WHERE anuncio > 0");
    $count = $stmt->fetchColumn();
    $duration1 = round((microtime(true) - $start) * 1000, 2);

    echo "Total anuncios: " . number_format($count) . "\n";
    echo "⏱ Tiempo: {$duration1}ms\n";
    if ($duration1 < 500) {
        echo "✅ EXCELENTE\n";
    } else {
        echo "⚠️ Puede mejorar\n";
    }
    echo "\n";

    // Test 2: Consulta con filtro vigente (usando índice)
    echo "========================================\n";
    echo "TEST 2: COUNT con filtro vigente\n";
    echo "========================================\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.anuncios WHERE vigente = 'V'");
    $count = $stmt->fetchColumn();
    $duration2 = round((microtime(true) - $start) * 1000, 2);

    echo "Total vigentes: " . number_format($count) . "\n";
    echo "⏱ Tiempo: {$duration2}ms\n";
    if ($duration2 < 500) {
        echo "✅ EXCELENTE\n";
    } else {
        echo "⚠️ Puede mejorar\n";
    }
    echo "\n";

    // Test 3: Consulta con filtro zona (usando índice)
    echo "========================================\n";
    echo "TEST 3: COUNT con filtro zona\n";
    echo "========================================\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.anuncios WHERE zona = 1");
    $count = $stmt->fetchColumn();
    $duration3 = round((microtime(true) - $start) * 1000, 2);

    echo "Total zona 1: " . number_format($count) . "\n";
    echo "⏱ Tiempo: {$duration3}ms\n";
    if ($duration3 < 500) {
        echo "✅ EXCELENTE\n";
    } else {
        echo "⚠️ Puede mejorar\n";
    }
    echo "\n";

    // Test 4: Consulta con filtro fecha (usando índice)
    echo "========================================\n";
    echo "TEST 4: COUNT con filtro fechas (6 meses)\n";
    echo "========================================\n\n";

    $fechaDesde = date('Y-m-d', strtotime('-6 months'));
    $fechaHasta = date('Y-m-d');

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM comun.anuncios
        WHERE fecha_otorgamiento >= :fecha_desde
        AND fecha_otorgamiento <= :fecha_hasta
    ");
    $stmt->execute([
        'fecha_desde' => $fechaDesde,
        'fecha_hasta' => $fechaHasta
    ]);
    $count = $stmt->fetchColumn();
    $duration4 = round((microtime(true) - $start) * 1000, 2);

    echo "Rango: {$fechaDesde} a {$fechaHasta}\n";
    echo "Total en rango: " . number_format($count) . "\n";
    echo "⏱ Tiempo: {$duration4}ms\n";
    if ($duration4 < 500) {
        echo "✅ EXCELENTE\n";
    } else {
        echo "⚠️ Puede mejorar\n";
    }
    echo "\n";

    // Test 5: SP de estadísticas
    echo "========================================\n";
    echo "TEST 5: SP de estadísticas\n";
    echo "========================================\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT * FROM comun.consulta_anuncios_estadisticas()");
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration5 = round((microtime(true) - $start) * 1000, 2);

    echo "Estadísticas obtenidas: " . count($stats) . "\n\n";
    foreach ($stats as $stat) {
        echo sprintf("  %-20s: %s (%s%%)\n",
            $stat['descripcion'],
            number_format($stat['total']),
            $stat['porcentaje']
        );
    }
    echo "\n⏱ Tiempo: {$duration5}ms\n";
    if ($duration5 < 1000) {
        echo "✅ EXCELENTE\n";
    } else {
        echo "⚠️ Puede mejorar\n";
    }
    echo "\n";

    // Test 6: Verificar índices están siendo usados
    echo "========================================\n";
    echo "TEST 6: EXPLAIN para verificar uso de índices\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        EXPLAIN (FORMAT TEXT)
        SELECT * FROM comun.anuncios
        WHERE vigente = 'V'
        AND fecha_otorgamiento >= CURRENT_DATE - INTERVAL '6 months'
        LIMIT 10
    ");

    $explain = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($explain as $line) {
        echo $line . "\n";
    }
    echo "\n";

    $explainText = implode(' ', $explain);
    if (strpos($explainText, 'Index Scan') !== false) {
        echo "✅ Está usando índices correctamente\n";
    } else {
        echo "⚠️ Revisar - puede no estar usando índices\n";
    }

    // Resumen
    echo "\n========================================\n";
    echo "RESUMEN DE PERFORMANCE\n";
    echo "========================================\n\n";

    echo sprintf("%-50s: %6.2fms\n", "COUNT sin filtros", $duration1);
    echo sprintf("%-50s: %6.2fms\n", "COUNT con vigente", $duration2);
    echo sprintf("%-50s: %6.2fms\n", "COUNT con zona", $duration3);
    echo sprintf("%-50s: %6.2fms\n", "COUNT con fechas", $duration4);
    echo sprintf("%-50s: %6.2fms\n", "SP estadísticas", $duration5);

    $promedio = ($duration1 + $duration2 + $duration3 + $duration4 + $duration5) / 5;
    echo "\nTiempo promedio: " . round($promedio, 2) . "ms\n";

    if ($promedio < 500) {
        echo "✅ EXCELENTE - Los índices están funcionando correctamente\n";
    } elseif ($promedio < 1000) {
        echo "✅ BUENO - Performance aceptable\n";
    } else {
        echo "⚠️ REGULAR - Considerar optimizaciones adicionales\n";
    }

    echo "\n✅ Pruebas completadas\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
