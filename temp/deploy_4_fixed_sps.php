<?php
/**
 * Despliega 4 SPs corregidos:
 * - RptPagosCaja (m.num_mercado_nvo)
 * - RptIngresos (seccion VARCHAR)
 * - RptPagosDetalle (public.usuarios, l.num_mercado)
 * - RptPagosGrl (seccion VARCHAR)
 */

$pdo = new PDO(
    "pgsql:host=192.168.6.146;port=5432;dbname=mercados",
    "refact",
    "FF)-BQk2",
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$base = 'RefactorX/Base/mercados/database/database/';
$files = [
    'RptPagosCaja_sp_rpt_pagos_caja.sql',
    'RptIngresos_sp_rpt_ingresos_locales.sql',
    'RptPagosDetalle_sp_rpt_pagos_detalle.sql',
    'RptPagosGrl_sp_rpt_pagos_grl.sql'
];

echo "🚀 Desplegando 4 SPs corregidos:\n\n";

foreach ($files as $file) {
    $filepath = $base . $file;

    if (!file_exists($filepath)) {
        echo "❌ $file NO EXISTE\n";
        continue;
    }

    $sql = file_get_contents($filepath);

    try {
        $pdo->exec($sql);
        echo "✅ $file desplegado correctamente\n";
    } catch (PDOException $e) {
        echo "❌ $file ERROR:\n";
        echo "   " . substr($e->getMessage(), 0, 150) . "...\n\n";
    }
}

echo "\n✅ Proceso completado\n";
?>
