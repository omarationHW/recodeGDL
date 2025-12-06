<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🧪 Probando componentes con parámetros correctos:\n\n";

$tests = [
    [
        'name' => 'EnergiaModif',
        'sp' => 'sp_energia_modif_buscar',
        'query' => "SELECT * FROM public.sp_energia_modif_buscar(1, 1, 1, '01', 1, 'A', '1') LIMIT 1"
    ],
    [
        'name' => 'RptEmisionLaser',
        'sp' => 'sp_rpt_emision_laser',
        'query' => "SELECT * FROM public.sp_rpt_emision_laser(1, 2024, 1, 1) LIMIT 1"
    ],
    [
        'name' => 'RptFacturaEmision',
        'sp' => 'sp_rpt_factura_emision',
        'query' => "SELECT * FROM public.sp_rpt_factura_emision(1, 2024, 1, 1, 1) LIMIT 1"
    ],
    [
        'name' => 'RptFacturaEnergia',
        'sp' => 'rpt_factura_energia',
        'query' => "SELECT * FROM public.rpt_factura_energia(1, 2024, 1, 1) LIMIT 1"
    ],
    [
        'name' => 'RptMercados',
        'sp' => 'sp_reporte_catalogo_mercados',
        'query' => "SELECT * FROM public.sp_reporte_catalogo_mercados() LIMIT 5"
    ],
    [
        'name' => 'RptMovimientos',
        'sp' => 'sp_get_movimientos_locales',
        'query' => "SELECT * FROM public.sp_get_movimientos_locales('2024-01-01', '2024-12-31', 1) LIMIT 5"
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
        $msg = explode("\n", $e->getMessage())[0];
        echo "  ❌ ERROR: " . substr($msg, 0, 150) . "...\n\n";
        $errors[] = ['name' => $test['name'], 'sp' => $test['sp'], 'error' => $msg];
    }
}

echo str_repeat("=", 60) . "\n";
echo "📊 RESULTADO: $working de " . count($tests) . " componentes funcionando\n";
echo str_repeat("=", 60) . "\n";

if (count($errors) > 0) {
    echo "\n❌ COMPONENTES CON ERRORES:\n\n";
    foreach ($errors as $err) {
        echo "• {$err['name']} ({$err['sp']})\n";
        echo "  " . substr($err['error'], 0, 180) . "...\n\n";
    }
}
?>
