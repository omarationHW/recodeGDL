<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

$base = 'RefactorX/Base/mercados/database/database/';

// Lista de archivos SQL a desplegar (preferir _CORREGIDO si existe)
$files = [
    // EnergiaModif
    'EnergiaModif_sp_energia_modif_buscar.sql',
    'EnergiaModif_sp_energia_modif_modificar.sql',
    'EnergiaModif_sp_catalogo_secciones.sql',
    
    // RptEmisionRbosAbastos
    'RptEmisionRbosAbastos_sp_rpt_emision_rbos_abastos_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_get_requerimientos_abastos_CORREGIDO.sql',
    'RptEmisionRbosAbastos_sp_get_recargos_mes_abastos_CORREGIDO.sql',
    
    // RptEmisionLaser
    'RptEmisionLaser_sp_rpt_emision_laser.sql',
    'RptEmisionLaser_sp_get_fecha_descuento.sql',
    'RptEmisionLaser_sp_get_locales_emision_laser.sql',
    'RptEmisionLaser_sp_get_mes_adeudo.sql',
    'RptEmisionLaser_sp_get_pagos_local.sql',
    'RptEmisionLaser_sp_get_recargos_mes.sql',
    'RptEmisionLaser_sp_get_requerimientos.sql',
    'RptEmisionLaser_sp_get_subtotal_local.sql',
    
    // RptFacturaEmision
    'RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql',
    'RptFacturaEmision_sp_get_vencimiento_rec_CORREGIDO.sql',
    
    // RptFacturaEnergia
    'RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql',
    
    // RptMovimientos
    'RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql'
];

echo "🚀 Desplegando " . count($files) . " SPs:\n\n";

$deployed = 0;
$errors = [];

foreach ($files as $file) {
    $filepath = $base . $file;
    
    if (!file_exists($filepath)) {
        echo "⚠️  SKIP: $file (no existe)\n";
        continue;
    }
    
    try {
        $sql = file_get_contents($filepath);
        $pdo->exec($sql);
        echo "✅ $file\n";
        $deployed++;
    } catch (PDOException $e) {
        $msg = explode("\n", $e->getMessage())[0];
        echo "❌ $file:\n";
        echo "   " . substr($msg, 0, 100) . "...\n\n";
        $errors[] = ['file' => $file, 'error' => $msg];
    }
}

echo "\n" . str_repeat("=", 60) . "\n";
echo "📊 RESUMEN: $deployed SPs desplegados, " . count($errors) . " errores\n";
echo str_repeat("=", 60) . "\n";

if (count($errors) > 0) {
    echo "\n❌ ERRORES:\n\n";
    foreach ($errors as $err) {
        echo "• {$err['file']}\n";
        echo "  " . substr($err['error'], 0, 120) . "...\n\n";
    }
}
?>
