<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

echo "🚀 Desplegando 2 SPs corregidos:\n\n";

$files = ['RptPagosCaja_sp_rpt_pagos_caja.sql', 'RptPagosDetalle_sp_rpt_pagos_detalle.sql'];

foreach ($files as $file) {
    try {
        $pdo->exec(file_get_contents('RefactorX/Base/mercados/database/database/' . $file));
        echo "✅ $file desplegado\n";
    } catch (PDOException $e) {
        echo "❌ $file: " . substr($e->getMessage(), 0, 100) . "\n";
    }
}

echo "\n✅ Completado\n";
?>
