<?php
/**
 * Corrige referencias al schema antiguo "comun" en 4 componentes
 */

$base = 'RefactorX/Base/mercados/database/database/';

$files = [
    'EnergiaModif_sp_energia_modif_buscar.sql',
    'RptFacturaEmision_sp_rpt_factura_emision_CORREGIDO.sql',
    'RptFacturaEnergia_rpt_factura_energia_CORREGIDO.sql',
    'RptMovimientos_sp_get_movimientos_locales_CORREGIDO.sql'
];

echo "🔧 Corrigiendo referencias 'comun.' → 'publico.' en 4 archivos:\n\n";

foreach ($files as $file) {
    $filepath = $base . $file;
    
    if (!file_exists($filepath)) {
        echo "❌ $file NO EXISTE\n";
        continue;
    }
    
    $content = file_get_contents($filepath);
    $original = $content;
    
    // Reemplazar comun. por publico.
    $content = preg_replace('/\bcomun\./', 'publico.', $content, -1, $count);
    
    if ($count > 0) {
        file_put_contents($filepath, $content);
        echo "✅ $file ($count cambios)\n";
    } else {
        echo "⚪ $file (sin cambios)\n";
    }
}

echo "\n✅ Proceso completado\n";
?>
