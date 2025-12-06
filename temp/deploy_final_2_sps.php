<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$base = 'RefactorX/Base/mercados/database/database/';
$files = [
    'RptCatalogoMerc_sp_reporte_catalogo_mercados.sql',
    'RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos.sql'  // Try non-CORREGIDO version
];

echo "🚀 Desplegando 2 SPs finales:\n\n";

foreach ($files as $file) {
    try {
        $pdo->exec(file_get_contents($base . $file));
        echo "✅ $file\n";
    } catch (PDOException $e) {
        echo "❌ $file:\n";
        echo "   " . substr($e->getMessage(), 0, 150) . "...\n\n";
    }
}

echo "\n✅ Completado\n";
?>
