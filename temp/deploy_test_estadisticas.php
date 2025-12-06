<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando Estadisticas (3 SPs):\n\n";

$sps = [
    'sp_estadisticas_global' => 'Estadisticas_sp_estadisticas_global.sql',
    'sp_estadisticas_importe' => 'Estadisticas_sp_estadisticas_importe.sql',
    'sp_desgloce_adeudos_por_importe' => 'Estadisticas_sp_desgloce_adeudos_por_importe.sql'
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

// Test 1: sp_estadisticas_global
try {
    echo "1. sp_estadisticas_global(2024, 12):\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_estadisticas_global(2024, 12) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n\n";
}

// Test 2: sp_estadisticas_importe
try {
    echo "2. sp_estadisticas_importe(2024, 12, 1000):\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_estadisticas_importe(2024, 12, 1000) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n\n";
}

// Test 3: sp_desgloce_adeudos_por_importe
try {
    echo "3. sp_desgloce_adeudos_por_importe(2024, 12, 1000):\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_desgloce_adeudos_por_importe(2024, 12, 1000) LIMIT 5");
    $count = $stmt->rowCount();
    echo "   ✅ OK - $count registros encontrados\n\n";
} catch (PDOException $e) {
    echo "   ❌ ERROR: " . $e->getMessage() . "\n\n";
}

echo "✅ Estadisticas componente completado!\n";
?>
