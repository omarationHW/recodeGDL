<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando RptFacturaEnergia corregido:\n\n";

try {
    $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql'));
    echo "✅ RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql desplegado\n\n";
    
    echo "🧪 Probando SP:\n";
    $stmt = $pdo->query("SELECT * FROM public.rpt_factura_energia(1, 2024, 1, 1) LIMIT 1");
    $count = $stmt->rowCount();
    echo "✅ OK - $count registros encontrados\n";
    
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
?>
