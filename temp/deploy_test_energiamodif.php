<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando EnergiaModif corregido:\n\n";

try {
    $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/EnergiaModif_sp_energia_modif_buscar.sql'));
    echo "✅ EnergiaModif_sp_energia_modif_buscar.sql desplegado\n\n";
    
    echo "🧪 Probando SP:\n";
    $stmt = $pdo->query("SELECT * FROM public.sp_energia_modif_buscar(1, 1, 1, '01', 1, 'A', '1') LIMIT 1");
    $count = $stmt->rowCount();
    echo "✅ OK - $count registros encontrados\n";
    
} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
?>
