<?php
/**
 * Corrige la definición del schema de los SPs
 * - DROP FUNCTION debe ser public.sp_name
 * - CREATE FUNCTION debe ser public.sp_name
 * - Las TABLAS dentro del SP usan publico.table_name
 */

$base_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\';

$files = [
    'RptIngresos_sp_rpt_ingresos_locales.sql',
    'RptIngresosEnergia_sp_rpt_ingresos_energia.sql',
    'RptPagosCaja_sp_rpt_pagos_caja.sql',
    'RptPagosDetalle_sp_rpt_pagos_detalle.sql',
    'RptPagosGrl_sp_rpt_pagos_grl.sql'
];

echo "Corrigiendo schema de definición de SPs:\n\n";

foreach ($files as $file) {
    $filepath = $base_path . $file;

    if (!file_exists($filepath)) {
        echo "❌ $file NO EXISTE\n";
        continue;
    }

    $content = file_get_contents($filepath);
    $original = $content;

    // Fix DROP FUNCTION: publico.sp_name → public.sp_name
    $content = preg_replace('/DROP FUNCTION IF EXISTS publico\./', 'DROP FUNCTION IF EXISTS public.', $content, -1, $count1);

    // Fix CREATE FUNCTION: publico.sp_name → public.sp_name
    $content = preg_replace('/CREATE OR REPLACE FUNCTION publico\./', 'CREATE OR REPLACE FUNCTION public.', $content, -1, $count2);

    $total_changes = $count1 + $count2;

    if ($total_changes > 0) {
        file_put_contents($filepath, $content);
        echo "✅ $file ($total_changes cambios)\n";
    } else {
        echo "⚪ $file (sin cambios)\n";
    }
}

echo "\n✅ Proceso completado\n";
?>
