<?php
/**
 * Corrige configuración de Base en archivos Vue
 * Cambia Base: 'padron_licencias' → Base: 'mercados' donde sea necesario
 *
 * REGLA: Si el SP usa ta_11_pagos_local, ta_11_adeudo_local u otras tablas
 * que SOLO existen en mercados, el Vue debe usar Base: 'mercados'
 */

// SPs que definitivamente usan tablas de mercados
$components_to_fix = [
    'Estadisticas',
    'EnergiaModif',
    'Prescripcion',
    'RptEmisionRbosAbastos',
    'RptEmisionLaser',
    'RptFacturaEmision',
    'RptFacturaEnergia',
    'RptFacturaGLunes',
    'RptLocalesGiro',
    'RptMercados',
    'RptIngresos',
    'RptIngresosEnergia',
    'RptPagosAno',
    'RptPagosCaja',
    'RptPagosDetalle',
    'RptPagosGrl'
];

$base_vue_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\FrontEnd\\src\\views\\modules\\mercados\\';
$backup_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\temp\\backup_vue\\';

// Create backup directory
if (!is_dir($backup_path)) {
    mkdir($backup_path, 0777, true);
}

$report = [];
$totalFixed = 0;

foreach ($components_to_fix as $comp_name) {
    $vue_file = $base_vue_path . $comp_name . '.vue';

    if (!file_exists($vue_file)) {
        $report[] = [
            'component' => $comp_name,
            'status' => '❌ NO EXISTE',
            'changes' => 0
        ];
        continue;
    }

    $content = file_get_contents($vue_file);
    $original_content = $content;

    // Backup original
    copy($vue_file, $backup_path . $comp_name . '.vue');

    // Count padron_licencias references BEFORE
    $count_before = preg_match_all('/Base:\s*[\'"]padron_licencias[\'"]/', $content);

    // Replace Base: 'padron_licencias' → Base: 'mercados'
    $content = preg_replace(
        '/Base:\s*[\'"]padron_licencias[\'"]/',
        "Base: 'mercados'",
        $content
    );

    // Count padron_licencias references AFTER
    $count_after = preg_match_all('/Base:\s*[\'"]padron_licencias[\'"]/', $content);

    $changes = $count_before - $count_after;

    if ($changes > 0) {
        // Save fixed content
        file_put_contents($vue_file, $content);
        $totalFixed++;

        $report[] = [
            'component' => $comp_name,
            'status' => '✅ CORREGIDO',
            'changes' => $changes
        ];
    } else {
        $report[] = [
            'component' => $comp_name,
            'status' => '⚪ SIN CAMBIOS',
            'changes' => 0
        ];
    }
}

// Generate report
echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  CORRECCIÓN MASIVA: Base Config en Vue                                   ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

foreach ($report as $r) {
    echo "{$r['status']} {$r['component']}.vue\n";
    if ($r['changes'] > 0) {
        echo "  Cambios aplicados: {$r['changes']}\n";
    }
    echo "\n";
}

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  RESUMEN                                                                  ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

echo "  Archivos corregidos: $totalFixed\n";
echo "  Backups guardados en: temp/backup_vue/\n\n";

echo "📝 Patrón de corrección aplicado:\n";
echo "  Base: 'padron_licencias' → Base: 'mercados'\n\n";

echo "✅ Proceso completado\n";
?>
