<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando RptMovimientos corregido:\n\n";

try {
    $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql'));
    echo "✅ RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql desplegado\n\n";
    
    echo "🧪 Probando SP:\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_get_movimientos_locales('2024-01-01', '2024-12-31', 1) LIMIT 5");
    $count = $stmt->rowCount();
    echo "✅ OK - $count registros encontrados\n";
    
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
?>
