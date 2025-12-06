<?php

$componentes = [
    'RptFacturaGLunes',
    'RptIngresos',
    'RptIngresosEnergia',
    'RptLocalesGiro',
    'RptMercados',
    'RptPagosDetalle',
    'RptPagosGrl',
    'RptSaldosLocales',
    'ZonasMercados'
];

$basePath = 'C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/FrontEnd/src/views/modules/mercados/';

$reporte = [];

foreach ($componentes as $comp) {
    $filePath = $basePath . $comp . '.vue';

    if (!file_exists($filePath)) {
        $reporte[$comp] = [
            'existe' => false,
            'error' => 'Archivo no encontrado'
        ];
        continue;
    }

    $contenido = file_get_contents($filePath);

    $info = [
        'existe' => true,
        'vue3_composition' => strpos($contenido, '<script setup>') !== false,
        'api_generic' => strpos($contenido, '/api/generic') !== false,
        'municipal_theme' => strpos($contenido, 'municipal-') !== false,
        'module_view' => strpos($contenido, 'module-view') !== false,
        'font_awesome' => strpos($contenido, 'font-awesome-icon') !== false,
        'toast' => strpos($contenido, 'useToast') !== false,
        'sps' => []
    ];

    // Buscar SPs
    preg_match_all('/Operacion:\s*[\'"]([^\'\"]+)[\'"]/', $contenido, $matches);
    if (!empty($matches[1])) {
        $info['sps'] = array_unique($matches[1]);
    }

    $reporte[$comp] = $info;
}

// Generar reporte
echo "\n╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║ ANÁLISIS DE 9 COMPONENTES NUEVOS - MÓDULO MERCADOS                          ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

echo "Fecha: " . date('Y-m-d H:i:s') . "\n\n";

foreach ($reporte as $comp => $info) {
    echo "═══════════════════════════════════════════════════════════════════════════════\n";
    echo "COMPONENTE: {$comp}.vue\n";
    echo "═══════════════════════════════════════════════════════════════════════════════\n";

    if (!$info['existe']) {
        echo "❌ ERROR: {$info['error']}\n\n";
        continue;
    }

    echo "Vue 3 Composition API: " . ($info['vue3_composition'] ? '✅ SÍ' : '❌ NO') . "\n";
    echo "/api/generic:           " . ($info['api_generic'] ? '✅ SÍ' : '❌ NO') . "\n";
    echo "municipal-theme.css:   " . ($info['municipal_theme'] ? '✅ SÍ' : '❌ NO') . "\n";
    echo "module-view:           " . ($info['module_view'] ? '✅ SÍ' : '❌ NO') . "\n";
    echo "FontAwesome:           " . ($info['font_awesome'] ? '✅ SÍ' : '❌ NO') . "\n";
    echo "Toast notifications:   " . ($info['toast'] ? '✅ SÍ' : '❌ NO') . "\n";

    echo "\nStored Procedures detectados:\n";
    if (empty($info['sps'])) {
        echo "  ⚠️  No se detectaron SPs en el componente\n";
    } else {
        foreach ($info['sps'] as $sp) {
            echo "  - {$sp}\n";
        }
    }

    echo "\n";
}

// Resumen general
echo "═══════════════════════════════════════════════════════════════════════════════\n";
echo "RESUMEN GENERAL\n";
echo "═══════════════════════════════════════════════════════════════════════════════\n";

$total = count($reporte);
$conVue3 = 0;
$conGeneric = 0;
$conMunicipal = 0;
$conModuleView = 0;

foreach ($reporte as $info) {
    if (!$info['existe']) continue;
    if ($info['vue3_composition']) $conVue3++;
    if ($info['api_generic']) $conGeneric++;
    if ($info['municipal_theme']) $conMunicipal++;
    if ($info['module_view']) $conModuleView++;
}

echo "Total componentes analizados:  {$total}\n";
echo "Vue 3 Composition API:         {$conVue3}/{$total}\n";
echo "/api/generic:                  {$conGeneric}/{$total}\n";
echo "municipal-theme.css:           {$conMunicipal}/{$total}\n";
echo "module-view:                   {$conModuleView}/{$total}\n\n";

if ($conVue3 == $total && $conGeneric == $total && $conMunicipal == $total && $conModuleView == $total) {
    echo "✅ TODOS LOS COMPONENTES ESTÁN CORRECTAMENTE IMPLEMENTADOS\n";
} else {
    echo "⚠️  ALGUNOS COMPONENTES REQUIEREN ATENCIÓN\n";
}

echo "\n";
