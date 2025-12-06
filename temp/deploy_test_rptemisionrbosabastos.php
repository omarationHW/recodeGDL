<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando RptEmisionRbosAbastos (3 SPs):\n\n";

$sps = [
    'sp_get_recargos_mes_abastos' => 'RptEmisionRbosAbastos_sp_get_recargos_mes_abastos_CORREGIDO.sql',
    'sp_get_requerimientos_abastos' => 'RptEmisionRbosAbastos_sp_get_requerimientos_abastos_CORREGIDO.sql',
    'sp_rpt_emision_rbos_abastos' => 'RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos_FINAL.sql'
];

foreach ($sps as $spName => $fileName) {
    try {
        $pdo->exec(file_get_contents("RefactorX/Base/mercados/database/database/$fileName"));
        echo "✅ $fileName desplegado\n";
    } catch (PDOException $e) {
        echo "❌ ERROR en $fileName: " . $e->getMessage() . "\n";
        exit(1);
    }
}

echo "\n🧪 Probando SPs:\n\n";

// Test 1: sp_get_recargos_mes_abastos
try {
    echo "1. sp_get_recargos_mes_abastos(2024, 12):\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_get_recargos_mes_abastos(2024, 12) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n\n";
}

// Test 2: sp_get_requerimientos_abastos
try {
    echo "2. sp_get_requerimientos_abastos(1):\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_get_requerimientos_abastos(1) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n\n";
}

// Test 3: sp_rpt_emision_rbos_abastos
try {
    echo "3. sp_rpt_emision_rbos_abastos(1, 1, 2024, 1):\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_emision_rbos_abastos(1, 1, 2024, 1) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n\n";
}

echo "✅ RptEmisionRbosAbastos componente completado!\n";
?>
