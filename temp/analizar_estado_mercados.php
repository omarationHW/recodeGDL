<?php
/**
 * Script para analizar estado de todos los componentes de Mercados
 */

$routerPath = "C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/FrontEnd/src/router/index.js";
$componentsPath = "C:/guadalajara/code/recodeGDLCurrent/recodeGDL/RefactorX/FrontEnd/src/views/modules/mercados/";

echo "\n=== ANÁLISIS DE COMPONENTES DE MERCADOS ===\n\n";

// 1. Leer el router y extraer rutas de mercados
$routerContent = file_get_contents($routerPath);

// Extraer todas las rutas de mercados (comentadas y no comentadas)
preg_match_all("/(\\/\\/)?.*?path: '\\/mercados\\/([^']+)'.*?component:.*?mercados\\/([^']+)\\.vue/s", $routerContent, $matches, PREG_SET_ORDER);

$rutasComentadas = [];
$rutasHabilitadas = [];

foreach ($matches as $match) {
    $esComentada = !empty($match[1]); // Si tiene // al inicio
    $path = $match[2];
    $componente = $match[3];

    if ($esComentada) {
        $rutasComentadas[] = ['path' => $path, 'component' => $componente];
    } else {
        $rutasHabilitadas[] = ['path' => $path, 'component' => $componente];
    }
}

echo "1. RUTAS HABILITADAS: " . count($rutasHabilitadas) . "\n";
echo str_repeat("-", 80) . "\n";
foreach ($rutasHabilitadas as $ruta) {
    $archivo = $componentsPath . $ruta['component'] . '.vue';
    $existe = file_exists($archivo) ? '✅' : '❌';
    echo "{$existe} {$ruta['path']} → {$ruta['component']}.vue\n";
}

echo "\n2. RUTAS COMENTADAS: " . count($rutasComentadas) . "\n";
echo str_repeat("-", 80) . "\n";
foreach ($rutasComentadas as $ruta) {
    $archivo = $componentsPath . $ruta['component'] . '.vue';
    $existe = file_exists($archivo) ? '✅ Existe' : '❌ No existe';
    echo "{$existe} → {$ruta['path']} ({$ruta['component']}.vue)\n";
}

// 3. Listar todos los archivos Vue en el directorio
echo "\n3. ARCHIVOS VUE EN DIRECTORIO: \n";
echo str_repeat("-", 80) . "\n";

$archivosVue = glob($componentsPath . "*.vue");
$componentesEnRouter = array_merge(
    array_column($rutasHabilitadas, 'component'),
    array_column($rutasComentadas, 'component')
);

foreach ($archivosVue as $archivo) {
    $nombre = basename($archivo, '.vue');
    $enRouter = in_array($nombre, $componentesEnRouter) ? '✅ En router' : '⚠️  Sin ruta';
    echo "{$enRouter} → {$nombre}.vue\n";
}

echo "\n" . str_repeat("=", 80) . "\n";
echo "RESUMEN:\n";
echo "  - Rutas habilitadas: " . count($rutasHabilitadas) . "\n";
echo "  - Rutas comentadas: " . count($rutasComentadas) . "\n";
echo "  - Archivos Vue: " . count($archivosVue) . "\n";
echo "\n";
