<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "TEST DE PERFORMANCE POST-ÍNDICES\n";
echo "========================================\n\n";

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$database", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conexión exitosa\n\n";

    $tests = [
        [
            'nombre' => 'SP sin filtros (10 registros)',
            'params' => [1, 10, null, null, null, null, null, null]
        ],
        [
            'nombre' => 'SP con filtro VIGENTE',
            'params' => [1, 10, null, null, 'VIGENTE', null, null, null]
        ],
        [
            'nombre' => 'SP con filtro zona=1',
            'params' => [1, 10, null, '1', null, null, null, null]
        ],
        [
            'nombre' => 'SP con filtro fechas (últimos 6 meses)',
            'params' => [1, 10, null, null, null, date('Y-m-d', strtotime('-6 months')), date('Y-m-d'), null]
        ],
        [
            'nombre' => 'SP con VIGENTE + últimos 6 meses',
            'params' => [1, 10, null, null, 'VIGENTE', date('Y-m-d', strtotime('-6 months')), date('Y-m-d'), null]
        ]
    ];

    foreach ($tests as $index => $test) {
        echo "========================================\n";
        echo "TEST " . ($index + 1) . ": " . $test['nombre'] . "\n";
        echo "========================================\n";

        $start = microtime(true);

        $stmt = $pdo->prepare("
            SELECT * FROM public.licenciasvigentesfrm_sp_licencias_vigentes(
                ?, ?, ?, ?, ?, ?, ?, ?
            )
        ");

        $stmt->execute($test['params']);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $duration = round((microtime(true) - $start) * 1000, 2);

        echo "⏱ Tiempo: {$duration}ms\n";
        echo "📊 Registros obtenidos: " . count($results) . "\n";

        if (count($results) > 0) {
            echo "📈 Total en BD: " . number_format($results[0]['total_records']) . "\n";
        }

        // Calificar el rendimiento
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
    }

    echo "========================================\n";
    echo "✅ PRUEBAS COMPLETADAS\n";
    echo "========================================\n";

} catch (Exception $e) {
    echo "\n✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
