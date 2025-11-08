<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST PERFORMANCE: c_giros POST-ÍNDICES\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    // Verificar índices
    echo "========================================\n";
    echo "ÍNDICES ACTUALES\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT indexname
        FROM pg_indexes
        WHERE schemaname = 'comun'
        AND tablename = 'c_giros'
        ORDER BY indexname
    ");

    $indices = $stmt->fetchAll(PDO::FETCH_COLUMN);
    foreach ($indices as $idx) {
        echo "  ✓ $idx\n";
    }
    echo "\nTotal índices: " . count($indices) . "\n\n";

    // Tests de performance
    echo "========================================\n";
    echo "TESTS DE PERFORMANCE\n";
    echo "========================================\n\n";

    $tests = [];

    // Test 1: Filtro tipo
    echo "Test 1: Filtro por tipo = 'L'\n";
    $start = microtime(true);
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.c_giros WHERE tipo = 'L'");
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);
    $tests[] = ['nombre' => 'Filtro tipo', 'duration' => $duration];
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    echo ($duration < 100 ? "  ✅ EXCELENTE\n" : "  ⚠️ Puede mejorar\n");
    echo "\n";

    // Test 2: Filtro vigente
    echo "Test 2: Filtro por vigente = 'V'\n";
    $start = microtime(true);
    $stmt = $pdo->query("SELECT COUNT(*) FROM comun.c_giros WHERE vigente = 'V'");
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);
    $tests[] = ['nombre' => 'Filtro vigente', 'duration' => $duration];
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    echo ($duration < 100 ? "  ✅ EXCELENTE\n" : "  ⚠️ Puede mejorar\n");
    echo "\n";

    // Test 3: Filtro combinado
    echo "Test 3: Filtro tipo + vigente (consulta típica)\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*)
        FROM comun.c_giros
        WHERE tipo = 'L' AND vigente = 'V'
    ");
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);
    $tests[] = ['nombre' => 'Filtro tipo + vigente', 'duration' => $duration];
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    echo ($duration < 100 ? "  ✅ EXCELENTE\n" : "  ⚠️ Puede mejorar\n");
    echo "\n";

    // Test 4: Búsqueda descripción
    echo "Test 4: Búsqueda por descripción (ILIKE '%comercio%')\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT COUNT(*)
        FROM comun.c_giros
        WHERE descripcion ILIKE '%comercio%'
    ");
    $count = $stmt->fetchColumn();
    $duration = round((microtime(true) - $start) * 1000, 2);
    $tests[] = ['nombre' => 'Búsqueda descripción', 'duration' => $duration];
    echo "  Resultados: " . number_format($count) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    echo ($duration < 200 ? "  ✅ EXCELENTE\n" : "  ⚠️ Puede mejorar\n");
    echo "\n";

    // Test 5: Consulta completa paginada
    echo "Test 5: Consulta completa con paginación (10 registros)\n";
    $start = microtime(true);
    $stmt = $pdo->query("
        SELECT *
        FROM comun.c_giros
        WHERE tipo = 'L'
        AND vigente = 'V'
        AND descripcion ILIKE '%comercio%'
        ORDER BY descripcion
        LIMIT 10
    ");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);
    $tests[] = ['nombre' => 'Consulta completa paginada', 'duration' => $duration];
    echo "  Resultados: " . count($results) . "\n";
    echo "  ⏱ Tiempo: {$duration}ms\n";
    echo ($duration < 200 ? "  ✅ EXCELENTE\n" : "  ⚠️ Puede mejorar\n");
    echo "\n";

    // Resumen
    echo "========================================\n";
    echo "RESUMEN DE PERFORMANCE\n";
    echo "========================================\n\n";

    $totalDuration = 0;
    foreach ($tests as $test) {
        echo sprintf("%-35s: %6.2fms\n", $test['nombre'], $test['duration']);
        $totalDuration += $test['duration'];
    }

    $promedio = $totalDuration / count($tests);
    echo "\nTiempo promedio: " . round($promedio, 2) . "ms\n";

    if ($promedio < 100) {
        echo "✅ EXCELENTE - Índices funcionando perfectamente\n";
    } elseif ($promedio < 200) {
        echo "✅ BUENO - Performance aceptable\n";
    } else {
        echo "⚠️ REGULAR - Considerar optimizaciones adicionales\n";
    }

    echo "\n✅ Pruebas completadas\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
