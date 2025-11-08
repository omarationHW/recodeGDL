<?php
$components = [
    'CatRequisitos.vue',
    'CatalogoActividadesFrm.vue',
    'doctosfrm.vue'
];

$base = 'C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/FrontEnd/src/views/modules/padron_licencias/';

foreach ($components as $component) {
    $file = $base . $component;
    
    if (!file_exists($file)) {
        echo "! $component - No encontrado\n";
        continue;
    }
    
    $content = file_get_contents($file);
    $changes = 0;
    
    // 1. Remove inline style
    if (strpos($content, 'style="position: relative;"') !== false) {
        $content = str_replace(' style="position: relative;"', '', $content);
        $changes++;
    }
    
    // 2. Fix badge-info to badge-purple  
    if (strpos($content, 'badge-info') !== false) {
        $content = str_replace('badge-info', 'badge-purple', $content);
        $changes++;
    }
    
    file_put_contents($file, $content);
    echo "✓ $component - $changes correcciones\n";
}

echo "\n✓ Completado\n";
