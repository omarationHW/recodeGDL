<?php
$components = [
    'RptEmisionLocales.vue',
    'RptEmisionRbosAbastos.vue',
    'RptEstadPagosyAdeudos.vue',
    'RptEstadisticaAdeudos.vue',
    'RptFacturaEmision.vue',
    'RptFacturaEnergia.vue',
    'RptFechasVencimiento.vue',
    'RptIngresoZonificado.vue',
    'RptMovimientos.vue',
    'RptPadronGlobal.vue'
];

$basePath = 'RefactorX/FrontEnd/src/views/modules/mercados/';

echo "═══════════════════════════════════════════════════════════════\n";
echo " ANÁLISIS DE 10 COMPONENTES Rpt*.vue PENDIENTES\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$results = [];

foreach ($components as $comp) {
    $filePath = $basePath . $comp;

    if (!file_exists($filePath)) {
        echo "⚠️  $comp - Archivo no existe\n";
        continue;
    }

    $content = file_get_contents($filePath);

    $result = [
        'name' => $comp,
        'exists' => true,
        'setup' => strpos($content, '<script setup>') !== false,
        'options' => strpos($content, 'export default') !== false,
        'api_generic' => strpos($content, '/api/generic') !== false,
        'api_execute' => strpos($content, '/api/execute') !== false,
        'municipal_theme' => strpos($content, 'municipal-theme') !== false,
        'module_view' => strpos($content, 'module-view') !== false,
        'size' => strlen($content)
    ];

    $results[] = $result;

    // Print summary
    $api = $result['api_generic'] ? '✅ /api/generic' : ($result['api_execute'] ? '❌ /api/execute' : '⚠️  Sin API');
    $vue = $result['setup'] ? '✅ Vue 3 Setup' : ($result['options'] ? '❌ Options API' : '⚠️  Unknown');
    $theme = $result['municipal_theme'] ? '✅ municipal-theme' : '❌ Sin theme';
    $view = $result['module_view'] ? '✅ module-view' : '❌ Sin module-view';

    echo str_pad($comp, 35) . " | $vue | $api | $theme | $view\n";
}

echo "\n═══════════════════════════════════════════════════════════════\n";
echo " RESUMEN\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$countSetup = count(array_filter($results, fn($r) => $r['setup']));
$countOptions = count(array_filter($results, fn($r) => $r['options'] && !$r['setup']));
$countGeneric = count(array_filter($results, fn($r) => $r['api_generic']));
$countExecute = count(array_filter($results, fn($r) => $r['api_execute']));
$countTheme = count(array_filter($results, fn($r) => $r['municipal_theme']));
$countModuleView = count(array_filter($results, fn($r) => $r['module_view']));

echo "Vue 3 Composition API (setup):  $countSetup / " . count($results) . "\n";
echo "Vue 2 Options API:               $countOptions / " . count($results) . "\n";
echo "Usa /api/generic:                $countGeneric / " . count($results) . "\n";
echo "Usa /api/execute:                $countExecute / " . count($results) . "\n";
echo "Tiene municipal-theme.css:       $countTheme / " . count($results) . "\n";
echo "Tiene module-view pattern:       $countModuleView / " . count($results) . "\n";

echo "\n📋 ACCIONES REQUERIDAS:\n";
if ($countOptions > 0) echo "   - Migrar $countOptions componentes de Options API a Composition API\n";
if ($countExecute > 0) echo "   - Cambiar $countExecute componentes de /api/execute a /api/generic\n";
if (count($results) - $countTheme > 0) echo "   - Aplicar municipal-theme.css a " . (count($results) - $countTheme) . " componentes\n";
if (count($results) - $countModuleView > 0) echo "   - Aplicar module-view pattern a " . (count($results) - $countModuleView) . " componentes\n";

echo "\n";
