<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando RptIngresosEnergia:\n\n";

try {
    $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/RptIngresosEnergia_sp_rpt_ingresos_energia.sql'));
    echo "✅ RptIngresosEnergia desplegado correctamente\n\n";
    
    echo "🧪 Probando SP:\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_ingresos_energia(1, 2024, NULL, NULL) LIMIT 5");
    $count = $stmt->rowCount();
    echo "✅ OK - $count registros encontrados\n";
    
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
?>
