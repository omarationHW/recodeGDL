<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST PERFORMANCE ANUNCIOS POST-ÍNDICES\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    $tests = [
        [
            'nombre' => 'SP consulta sin filtros (10 registros)',
            'descripcion' => 'Consulta básica sin filtros de búsqueda'
        ],
        [
            'nombre' => 'SP consulta con filtro VIGENTE',
            'descripcion' => 'Filtro por anuncios vigentes'
        ],
        [
            'nombre' => 'SP consulta con filtro zona',
            'descripcion' => 'Filtro por zona específica'
        ],
        [
            'nombre' => 'SP consulta con filtro fechas (últimos 6 meses)',
            'descripcion' => 'Filtro por rango de fechas de otorgamiento'
        ],
        [
            'nombre' => 'SP estadísticas completas',
            'descripcion' => 'Obtener todas las estadísticas de anuncios'
        ]
    ];

    $resultados = [];

    // Test 1: Sin filtros
    echo "========================================\n";
    echo "TEST 1: {$tests[0]['nombre']}\n";
    echo "========================================\n";
    echo "{$tests[0]['descripcion']}\n\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM comun.consulta_anuncios_list(
            null, null, null, null, null, null, null, null, null, null, null, 1, 10
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    $resultados[] = [
        'test' => $tests[0]['nombre'],
        'duration' => $duration
    ];

    echo "⏱ Tiempo: {$duration}ms\n";
    echo "📊 Registros: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "📈 Total en BD: " . number_format($results[0]['total_records']) . "\n";
    }

    if ($duration < 500) {
        echo "✅ EXCELENTE\n";
    } elseif ($duration < 1000) {
        echo "✅ BUENO\n";
    } elseif ($duration < 3000) {
        echo "⚠️ ACEPTABLE\n";
    } else {
        echo "❌ LENTO\n";
    }
    echo "\n";

    // Test 2: Con filtro VIGENTE
    echo "========================================\n";
    echo "TEST 2: {$tests[1]['nombre']}\n";
    echo "========================================\n";
    echo "{$tests[1]['descripcion']}\n\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM comun.consulta_anuncios_list(
            null, null, null, null, null, null, null, 'V', null, null, null, 1, 10
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    $resultados[] = [
        'test' => $tests[1]['nombre'],
        'duration' => $duration
    ];

    echo "⏱ Tiempo: {$duration}ms\n";
    echo "📊 Registros: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "📈 Total vigentes: " . number_format($results[0]['total_records']) . "\n";
    }

    if ($duration < 500) {
        echo "✅ EXCELENTE\n";
    } elseif ($duration < 1000) {
        echo "✅ BUENO\n";
    } else {
        echo "⚠️ NECESITA MEJORA\n";
    }
    echo "\n";

    // Test 3: Con filtro zona
    echo "========================================\n";
    echo "TEST 3: {$tests[2]['nombre']}\n";
    echo "========================================\n";
    echo "{$tests[2]['descripcion']}\n\n";

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM comun.consulta_anuncios_list(
            null, null, null, null, null, null, 1, null, null, null, null, 1, 10
        )
    ");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    $resultados[] = [
        'test' => $tests[2]['nombre'],
        'duration' => $duration
    ];

    echo "⏱ Tiempo: {$duration}ms\n";
    echo "📊 Registros: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "📈 Total en zona: " . number_format($results[0]['total_records']) . "\n";
    }

    if ($duration < 500) {
        echo "✅ EXCELENTE\n";
    } elseif ($duration < 1000) {
        echo "✅ BUENO\n";
    } else {
        echo "⚠️ NECESITA MEJORA\n";
    }
    echo "\n";

    // Test 4: Con filtro fechas
    echo "========================================\n";
    echo "TEST 4: {$tests[3]['nombre']}\n";
    echo "========================================\n";
    echo "{$tests[3]['descripcion']}\n\n";

    $fechaDesde = date('Y-m-d', strtotime('-6 months'));
    $fechaHasta = date('Y-m-d');

    $start = microtime(true);
    $stmt = $pdo->prepare("
        SELECT * FROM comun.consulta_anuncios_list(
            null, null, null, null, null, null, null, null, :fecha_desde, :fecha_hasta, null, 1, 10
        )
    ");
    $stmt->execute([
        'fecha_desde' => $fechaDesde,
        'fecha_hasta' => $fechaHasta
    ]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    $resultados[] = [
        'test' => $tests[3]['nombre'],
        'duration' => $duration
    ];

    echo "⏱ Tiempo: {$duration}ms\n";
    echo "📊 Registros: " . count($results) . "\n";
    echo "📅 Rango: {$fechaDesde} a {$fechaHasta}\n";
    if (count($results) > 0) {
        echo "📈 Total en rango: " . number_format($results[0]['total_records']) . "\n";
    }

    if ($duration < 500) {
        echo "✅ EXCELENTE\n";
    } elseif ($duration < 1000) {
        echo "✅ BUENO\n";
    } else {
        echo "⚠️ NECESITA MEJORA\n";
    }
    echo "\n";

    // Test 5: Estadísticas
    echo "========================================\n";
    echo "TEST 5: {$tests[4]['nombre']}\n";
    echo "========================================\n";
    echo "{$tests[4]['descripcion']}\n\n";

    $start = microtime(true);
    $stmt = $pdo->query("SELECT * FROM comun.consulta_anuncios_estadisticas()");
    $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $duration = round((microtime(true) - $start) * 1000, 2);

    $resultados[] = [
        'test' => $tests[4]['nombre'],
        'duration' => $duration
    ];

    echo "⏱ Tiempo: {$duration}ms\n";
    echo "📊 Estadísticas obtenidas: " . count($stats) . "\n\n";

    foreach ($stats as $stat) {
        echo sprintf("  %-20s: %s (%s%%)\n",
            $stat['descripcion'],
            number_format($stat['total']),
            $stat['porcentaje']
        );
    }
    echo "\n";

    if ($duration < 1000) {
        echo "✅ EXCELENTE\n";
    } elseif ($duration < 2000) {
        echo "✅ BUENO\n";
    } else {
        echo "⚠️ NECESITA MEJORA\n";
    }
    echo "\n";

    // Resumen
    echo "========================================\n";
    echo "RESUMEN DE PERFORMANCE\n";
    echo "========================================\n\n";

    $totalDuration = 0;
    foreach ($resultados as $resultado) {
        echo sprintf("%-50s: %6.2fms\n", $resultado['test'], $resultado['duration']);
        $totalDuration += $resultado['duration'];
    }

    $promedio = $totalDuration / count($resultados);
    echo "\n";
    echo "Tiempo promedio: " . round($promedio, 2) . "ms\n";

    if ($promedio < 500) {
        echo "✅ EXCELENTE - Rendimiento óptimo\n";
    } elseif ($promedio < 1000) {
        echo "✅ BUENO - Rendimiento aceptable\n";
    } else {
        echo "⚠️ REGULAR - Considerar más optimizaciones\n";
    }

    echo "\n✅ Pruebas completadas\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
