<?php
/**
 * Prueba todos los componentes uno por uno
 * Ejecuta cada SP con parámetros de prueba y reporta errores
 */

$pdo_mercados = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$pdo_padron = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$tests = [
    [
        'name' => 'ReporteGeneralMercados',
        'sp' => 'sp_reporte_general_mercados',
        'db' => 'mercados',
        'params' => [1, 2010, 1],
        'description' => 'Reporte general de estadísticas'
    ],
    [
        'name' => 'Estadisticas',
        'sp' => 'sp_estadistica_pagos_adeudos',
        'db' => 'mercados',
        'params' => [1, 2010, 1, 2010, 12],
        'description' => 'Estadísticas de pagos y adeudos'
    ],
    [
        'name' => 'Prescripcion',
        'sp' => 'sp_listar_adeudos_energia',
        'db' => 'mercados',
        'params' => [1],
        'description' => 'Listado de adeudos de energía'
    ],
    [
        'name' => 'RptFacturaGLunes',
        'sp' => 'sp_rpt_factura_global',
        'db' => 'mercados',
        'params' => [1, 2010, 1],
        'description' => 'Factura global Lunes'
    ],
    [
        'name' => 'RptLocalesGiro',
        'sp' => 'sp_rpt_locales_giro',
        'db' => 'mercados',
        'params' => [1, null, null],
        'description' => 'Reporte de locales por giro'
    ],
    [
        'name' => 'RptIngresos',
        'sp' => 'sp_rpt_ingresos_locales',
        'db' => 'mercados',
        'params' => ['2010-01-01', '2010-01-31', 1],
        'description' => 'Reporte de ingresos locales'
    ],
    [
        'name' => 'RptIngresosEnergia',
        'sp' => 'sp_rpt_ingresos_energia',
        'db' => 'mercados',
        'params' => ['2010-01-01', '2010-01-31', 1],
        'description' => 'Reporte de ingresos energía'
    ],
    [
        'name' => 'RptPagosAno',
        'sp' => 'sp_rpt_pagos_ano',
        'db' => 'mercados',
        'params' => [2010, 1, null],
        'description' => 'Reporte de pagos por año'
    ],
    [
        'name' => 'RptPagosCaja',
        'sp' => 'sp_rpt_pagos_caja',
        'db' => 'mercados',
        'params' => [1, 2010, 1, null],
        'description' => 'Reporte de pagos por caja'
    ],
    [
        'name' => 'RptPagosDetalle',
        'sp' => 'sp_rpt_pagos_detalle',
        'db' => 'mercados',
        'params' => [1, 2010, 1],
        'description' => 'Reporte detalle de pagos'
    ],
    [
        'name' => 'RptPagosGrl',
        'sp' => 'sp_rpt_pagos_grl',
        'db' => 'mercados',
        'params' => ['2010-01-01', '2010-01-31', 1],
        'description' => 'Reporte pagos generales'
    ]
];

$results = [];
$passed = 0;
$failed = 0;

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  PRUEBA INDIVIDUAL: Componentes Marcados con ---                         ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

foreach ($tests as $test) {
    $pdo = $test['db'] === 'mercados' ? $pdo_mercados : $pdo_padron;

    echo "🔍 Probando: {$test['name']}\n";
    echo "   SP: {$test['sp']}\n";
    echo "   Base: {$test['db']}\n";
    echo "   Parámetros: " . json_encode($test['params']) . "\n";

    try {
        // Build placeholders
        $placeholders = implode(',', array_fill(0, count($test['params']), '?'));
        $sql = "SELECT * FROM public.{$test['sp']}($placeholders)";

        $stmt = $pdo->prepare($sql);
        $stmt->execute($test['params']);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $passed++;
        echo "   ✅ EXITOSO: " . count($rows) . " registros\n";

        if (count($rows) > 0) {
            $columns = array_keys($rows[0]);
            echo "   Columnas: " . implode(', ', array_slice($columns, 0, 5));
            if (count($columns) > 5) echo "...";
            echo "\n";
        }

        $results[] = [
            'name' => $test['name'],
            'status' => 'OK',
            'rows' => count($rows),
            'error' => null
        ];

    } catch (PDOException $e) {
        $failed++;
        $error = $e->getMessage();
        $short_error = substr($error, 0, 150);

        echo "   ❌ ERROR: $short_error";
        if (strlen($error) > 150) echo "...";
        echo "\n";

        $results[] = [
            'name' => $test['name'],
            'status' => 'FAILED',
            'rows' => 0,
            'error' => $error
        ];
    }

    echo "\n";
}

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  RESUMEN FINAL                                                            ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

echo "  Tests ejecutados: " . count($tests) . "\n";
echo "  ✅ Exitosos: $passed\n";
echo "  ❌ Fallidos: $failed\n\n";

if ($failed > 0) {
    echo "⚠️  COMPONENTES QUE REQUIEREN CORRECCIÓN:\n\n";
    foreach ($results as $r) {
        if ($r['status'] === 'FAILED') {
            echo "  • {$r['name']}\n";
            // Extract meaningful error parts
            if (preg_match('/ERROR:\s+([^\n]+)/', $r['error'], $matches)) {
                echo "    Error: {$matches[1]}\n";
            }
            if (preg_match('/LINE \d+:\s+([^\n]+)/', $r['error'], $matches)) {
                echo "    Línea: {$matches[1]}\n";
            }
            echo "\n";
        }
    }
} else {
    echo "🎉 TODOS LOS COMPONENTES FUNCIONAN CORRECTAMENTE\n";
}

// Save detailed report
file_put_contents('temp/test_results.json', json_encode($results, JSON_PRETTY_PRINT));
echo "📄 Reporte detallado guardado en: temp/test_results.json\n";
?>
