<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando RptFacturaEmision corregido:\n\n";

try {
    $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql'));
    echo "✅ RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql desplegado\n\n";
    
    echo "🧪 Probando SP:\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_rpt_factura_emision(1, 2024, 1, 1, 1) LIMIT 1");
    $count = $stmt->rowCount();
    echo "✅ OK - $count registros encontrados\n";
    
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
?>
