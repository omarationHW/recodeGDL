<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$base = 'RefactorX/Base/mercados/database/database/';
$files = [
    'EnergiaModif_sp_energia_modif_buscar.sql',
    'RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql',
    'RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql',
    'RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql'
];

echo "🚀 Desplegando 4 SPs corregidos:\n\n";

$deployed = 0;
$errors = [];

foreach ($files as $file) {
    try {
        $pdo->exec(file_get_contents($base . $file));
        echo "✅ $file\n";
        $deployed++;
    } catch (PDOException $e) {
        $msg = explode("\n", $e->getMessage())[0];
        echo "❌ $file:\n";
        echo "   " . substr($msg, 0, 120) . "...\n\n";
        $errors[] = ['file' => $file, 'error' => $msg];
    }
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "📊 RESULTADO: $deployed SPs desplegados\n";
echo str_repeat("=", 60) . "\n";

if (count($errors) > 0) {
    echo "\n❌ ERRORES:\n";
    foreach ($errors as $err) {
        echo "• {$err['file']}\n";
        echo "  " . substr($err['error'], 0, 150) . "...\n\n";
    }
} else {
    echo "\n🧪 Probando SPs desplegados:\n\n";
    
    $tests = [
        ['name' => 'EnergiaModif', 'query' => "SELECT * FROM public.sp_energia_modif_buscar(1, 1, 1, '01', 1, 'A', '1') LIMIT 1"],
        ['name' => 'RptFacturaEmision', 'query' => "SELECT * FROM public.sp_rpt_factura_emision(1, 2024, 1, 1, 1) LIMIT 1"],
        ['name' => 'RptFacturaEnergia', 'query' => "SELECT * FROM public.rpt_factura_energia(1, 2024, 1, 1) LIMIT 1"],
        ['name' => 'RptMovimientos', 'query' => "SELECT * FROM public.sp_get_movimientos_locales('2024-01-01', '2024-12-31', 1) LIMIT 5"]
    ];
    
    $working = 0;
    foreach ($tests as $test) {
        echo "🔍 {$test['name']}... ";
        try {
            $stmt = $pdo->query($test['query']);
            $count = $stmt->rowCount();
            echo "✅ OK ($count registros)\n";
            $working++;
        } catch (PDOException $e) {
            $msg = explode("\n", $e->getMessage())[0];
            echo "❌ ERROR\n";
            echo "   " . substr($msg, 0, 120) . "...\n";
        }
    }
    
    echo "\n📊 RESULTADO PRUEBAS: $working de " . count($tests) . " funcionando\n";
}
?>
