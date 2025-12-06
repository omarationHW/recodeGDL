<?php
/**
 * Corrige automáticamente los errores comunes restantes en los SPs
 */

$base_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\';

$fixes = [
    'RptIngresos_sp_rpt_ingresos_locales.sql' => [
        ['/\bl\.mercado\b/', 'l.num_mercado'],
        ['/\bpublic\./', 'publico.']
    ],
    'RptIngresosEnergia_sp_rpt_ingresos_energia.sql' => [
        ['/\bpublic\./', 'publico.']
    ],
    'RptPagosCaja_sp_rpt_pagos_caja.sql' => [
        ['/\bpublic\./', 'publico.']
    ],
    'RptPagosDetalle_sp_rpt_pagos_detalle.sql' => [
        ['/\bu\.id_usuario\b/', 'u.id'],
        ['/\bpublic\./', 'publico.']
    ],
    'RptPagosGrl_sp_rpt_pagos_grl.sql' => [
        ['/\bl\.mercado\b/', 'l.num_mercado'],
        ['/\bpublic\./', 'publico.']
    ]
];

$report = [];

foreach ($fixes as $file => $patterns) {
    $filepath = $base_path . $file;

    if (!file_exists($filepath)) {
        $report[] = ['file' => $file, 'status' => '❌ NO EXISTE'];
        continue;
    }

    $content = file_get_contents($filepath);
    $original = $content;
    $changes_count = 0;

    foreach ($patterns as [$pattern, $replacement]) {
        $new_content = preg_replace($pattern, $replacement, $content, -1, $count);
        if ($count > 0) {
            $content = $new_content;
            $changes_count += $count;
        }
    }

    if ($changes_count > 0) {
        file_put_contents($filepath, $content);
        $report[] = [
            'file' => $file,
            'status' => '✅ CORREGIDO',
            'changes' => $changes_count
        ];
    } else {
        $report[] = [
            'file' => $file,
            'status' => '⚪ SIN CAMBIOS',
            'changes' => 0
        ];
    }
}

echo "Correcciones automáticas aplicadas:\n\n";
foreach ($report as $r) {
    echo "{$r['status']} {$r['file']}";
    if (isset($r['changes']) && $r['changes'] > 0) {
        echo " ({$r['changes']} cambios)";
    }
    echo "\n";
}

echo "\n✅ Proceso completado\n";
?>
