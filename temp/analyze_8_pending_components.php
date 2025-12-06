<?php
/**
 * Script para analizar los 8 componentes pendientes del módulo Mercados
 * Según el prompt: Prescripción, Adeudos Condonados, Reporte General y Estadísticas,
 * Pagos por Año, Pagos por Caja, Zonificación, Resumen de Pagos
 */

$baseVuePath = 'C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/FrontEnd/src/views/modules/mercados/';
$baseSPPath = 'C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/Base/mercados/database/';

$components = [
    [
        'name' => 'Prescripción de Adeudos',
        'vue_file' => 'Prescripcion.vue',
        'router_path' => '/mercados/prescripcion',
        'router_commented' => true,
        'sidebar_label' => 'Prescripción de Adeudos',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_prescripcion_adeudos'
    ],
    [
        'name' => 'Reporte Adeudos Condonados',
        'vue_file' => 'RepAdeudCond.vue',
        'router_path' => '/mercados/rep-adeud-cond',
        'router_commented' => true,
        'sidebar_label' => 'Reporte Adeudos Condonados',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_reporte_adeudos_condonados'
    ],
    [
        'name' => 'Reporte General y Estadísticas',
        'vue_file' => 'ReporteGeneralMercados.vue',
        'router_path' => '/mercados/reporte-general-mercados',
        'router_commented' => true,
        'sidebar_label' => 'Reporte General y Estadísticas',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_reporte_general_mercados'
    ],
    [
        'name' => 'Estadísticas de Adeudos',
        'vue_file' => 'Estadisticas.vue',
        'router_path' => '/mercados/estadisticas',
        'router_commented' => true,
        'sidebar_label' => 'Estadísticas de Adeudos',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_estadisticas_adeudos'
    ],
    [
        'name' => 'Reporte Pagos por Año',
        'vue_file' => 'RptPagosAno.vue',
        'router_path' => '/mercados/rpt-pagos-ano',
        'router_commented' => true,
        'sidebar_label' => 'Reporte Pagos por Año',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_rpt_pagos_ano'
    ],
    [
        'name' => 'Reporte Pagos por Caja',
        'vue_file' => 'RptPagosCaja.vue',
        'router_path' => '/mercados/rpt-pagos-caja',
        'router_commented' => true,
        'sidebar_label' => 'Reporte Pagos por Caja',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_rpt_pagos_caja'
    ],
    [
        'name' => 'Reporte Zonificación',
        'vue_file' => 'RptZonificacion.vue',
        'router_path' => '/mercados/rpt-zonificacion',
        'router_commented' => true,
        'sidebar_label' => 'Reporte Zonificación',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_rpt_zonificacion'
    ],
    [
        'name' => 'Resumen de Pagos',
        'vue_file' => 'RptResumenPagos.vue',
        'router_path' => '/mercados/rpt-resumen-pagos',
        'router_commented' => true,
        'sidebar_label' => 'Resumen de Pagos',
        'sidebar_marker' => 'none',
        'expected_sp' => 'sp_rpt_resumen_pagos'
    ]
];

echo "\n╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ ANÁLISIS DE 8 COMPONENTES PENDIENTES - MÓDULO MERCADOS                      ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

$summary = [
    'vue_exist' => 0,
    'vue_missing' => 0,
    'sp_exist' => 0,
    'sp_missing' => 0,
    'ready_to_uncomment' => 0,
    'need_sp_creation' => 0,
    'need_vue_creation' => 0
];

foreach ($components as $index => $comp) {
    $num = $index + 1;
    echo "═══════════════════════════════════════════════════════════════════════════════\n";
    echo "[$num/8] {$comp['name']}\n";
    echo "═══════════════════════════════════════════════════════════════════════════════\n";

    // Check Vue file
    $vueFullPath = $baseVuePath . $comp['vue_file'];
    $vueExists = file_exists($vueFullPath);

    if ($vueExists) {
        echo "✅ Vue File: EXISTS - {$comp['vue_file']}\n";
        $summary['vue_exist']++;

        // Read Vue file to check structure
        $vueContent = file_get_contents($vueFullPath);
        $hasScriptSetup = strpos($vueContent, '<script setup>') !== false;
        $hasGenericAPI = strpos($vueContent, '/api/generic') !== false;
        $hasOperacion = preg_match('/Operacion:\s*[\'"]([^\'"]+)[\'"]/', $vueContent, $matches);

        echo "   - Script setup: " . ($hasScriptSetup ? "✅" : "❌") . "\n";
        echo "   - Generic API: " . ($hasGenericAPI ? "✅" : "❌") . "\n";

        if ($hasOperacion) {
            echo "   - SP Called: {$matches[1]}\n";
            $comp['actual_sp'] = $matches[1];
        } else {
            echo "   - SP Called: ❌ No detectado\n";
        }
    } else {
        echo "❌ Vue File: MISSING - {$comp['vue_file']}\n";
        $summary['vue_missing']++;
        $summary['need_vue_creation']++;
    }

    // Check SP files
    echo "\n";
    $spPattern = $baseSPPath . "**/{$comp['expected_sp']}*.sql";
    $spFiles = glob($baseSPPath . "database/{$comp['expected_sp']}*.sql");
    if (empty($spFiles)) {
        $spFiles = glob($baseSPPath . "ok/*{$comp['expected_sp']}*.sql");
    }

    if (!empty($spFiles)) {
        echo "✅ SP Found: " . basename($spFiles[0]) . "\n";
        $summary['sp_exist']++;
    } else {
        echo "❌ SP Missing: {$comp['expected_sp']}\n";
        $summary['sp_missing']++;
        $summary['need_sp_creation']++;
    }

    // Router status
    echo "\n";
    echo "📌 Router: " . ($comp['router_commented'] ? "⚠️  COMENTADO" : "✅ ACTIVO") . " - {$comp['router_path']}\n";
    echo "📌 Sidebar: Marcador '{$comp['sidebar_marker']}' - {$comp['sidebar_label']}\n";

    // Status summary
    echo "\n";
    if ($vueExists && !empty($spFiles) && !$comp['router_commented']) {
        echo "🎯 STATUS: ✅ COMPLETO Y LISTO\n";
        $summary['ready_to_uncomment']++;
    } elseif ($vueExists && !empty($spFiles) && $comp['router_commented']) {
        echo "🎯 STATUS: ⚠️  LISTO - Necesita descomentar router\n";
        $summary['ready_to_uncomment']++;
    } elseif ($vueExists && empty($spFiles)) {
        echo "🎯 STATUS: ⚠️  Vue OK - Falta SP\n";
    } elseif (!$vueExists && !empty($spFiles)) {
        echo "🎯 STATUS: ⚠️  SP OK - Falta Vue\n";
    } else {
        echo "🎯 STATUS: ❌ PENDIENTE - Falta Vue y SP\n";
    }

    echo "\n\n";
}

echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "RESUMEN GENERAL\n";
echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "Total componentes analizados:    8\n";
echo "\n";
echo "Archivos Vue:\n";
echo "  ✅ Existentes:                  {$summary['vue_exist']}\n";
echo "  ❌ Faltantes:                   {$summary['vue_missing']}\n";
echo "\n";
echo "Stored Procedures:\n";
echo "  ✅ Existentes:                  {$summary['sp_exist']}\n";
echo "  ❌ Faltantes:                   {$summary['sp_missing']}\n";
echo "\n";
echo "Acciones requeridas:\n";
echo "  📝 Crear archivos Vue:          {$summary['need_vue_creation']}\n";
echo "  📝 Crear/Migrar SPs:            {$summary['need_sp_creation']}\n";
echo "  📝 Descomentar en router:       " . ($summary['ready_to_uncomment']) . "\n";
echo "  📝 Marcar en AppSidebar:        8\n";
echo "\n";

$completionPercent = (($summary['vue_exist'] + $summary['sp_exist']) / 16) * 100;
echo "Progreso general: " . number_format($completionPercent, 1) . "%\n";
echo "\n";

if ($summary['need_vue_creation'] > 0 || $summary['need_sp_creation'] > 0) {
    echo "⚠️  RECOMENDACIÓN: Seguir flujo de trabajo con agentes según el prompt\n";
    echo "   1. AGENTE SP: Migrar/crear stored procedures faltantes\n";
    echo "   2. AGENTE VUE: Crear/completar archivos Vue\n";
    echo "   3. AGENTE BOOTSTRAP/UX: Validar estilos y UX\n";
    echo "   4. AGENTE VALIDADOR: Descomentar rutas y marcar en sidebar\n";
    echo "   5. AGENTE LIMPIEZA: Limpiar temporales y actualizar control\n";
} else {
    echo "✅ TODOS LOS COMPONENTES ESTÁN LISTOS PARA INTEGRACIÓN\n";
}

echo "\n";
