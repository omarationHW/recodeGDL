<?php
/**
 * Prueba los 7 componentes restantes
 */

$pdo = new PDO(
    "pgsql:host=192.168.6.146;port=5432;dbname=mercados",
    "refact",
    "FF)-BQk2",
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

echo "🧪 Probando 7 componentes restantes:\n\n";

$tests = [
    [
        'name' => 'EnergiaModif',
        'sp' => 'sp_energia_modif_buscar',
        'query' => "SELECT * FROM public.sp_energia_modif_buscar(1, 1, 1, 'A') LIMIT 5"
    ],
    [
        'name' => 'RptEmisionRbosAbastos',
        'sp' => 'sp_rpt_emision_rbos_abastos',
        'query' => "SELECT * FROM public.sp_rpt_emision_rbos_abastos(1, 2024, 1) LIMIT 5"
    ],
    [
        'name' => 'RptEmisionLaser',
        'sp' => 'sp_rpt_emision_laser',
        'query' => "SELECT * FROM public.sp_rpt_emision_laser(1, 2024, 1) LIMIT 5"
    ],
    [
        'name' => 'RptFacturaEmision',
        'sp' => 'sp_rpt_factura_emision',
        'query' => "SELECT * FROM public.sp_rpt_factura_emision(1, 2024, 1) LIMIT 5"
    ],
    [
        'name' => 'RptFacturaEnergia',
        'sp' => 'sp_rpt_factura_energia',
        'query' => "SELECT * FROM public.sp_rpt_factura_energia(1, 2024, 1, 1) LIMIT 5"
    ],
    [
        'name' => 'RptMercados',
        'sp' => 'sp_rpt_mercados',
        'query' => "SELECT * FROM public.sp_rpt_mercados(1) LIMIT 5"
    ],
    [
        'name' => 'RptMovimientos',
        'sp' => 'sp_rpt_movimientos',
        'query' => "SELECT * FROM public.sp_rpt_movimientos(1, '2024-01-01', '2024-12-31', NULL) LIMIT 5"
    ]
];

$working = 0;
$errors = [];

foreach ($tests as $test) {
    echo "🔍 {$test['name']} ({$test['sp']})...\n";
    
    try {
        $stmt = $pdo->query($test['query']);
        $count = $stmt->rowCount();
        echo "  ✅ OK - $count registros encontrados\n\n";
        $working++;
    } catch (PDOException $e) {
        $msg = $e->getMessage();
        // Extract just the first line of error
        $first_line = explode("\n", $msg)[0];
        echo "  ❌ ERROR: " . substr($first_line, 0, 100) . "...\n\n";
        $errors[] = [
            'component' => $test['name'],
            'sp' => $test['sp'],
            'error' => $first_line
        ];
    }
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "📊 RESUMEN: $working de 7 componentes funcionando\n";
echo str_repeat("=", 60) . "\n\n";

if (count($errors) > 0) {
    echo "❌ COMPONENTES CON ERRORES:\n\n";
    foreach ($errors as $err) {
        echo "• {$err['component']} ({$err['sp']})\n";
        echo "  Error: " . substr($err['error'], 0, 120) . "...\n\n";
    }
}
?>
