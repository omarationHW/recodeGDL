<?php
$components = [
    'EnergiaModif.vue',
    'RptEmisionRbosAbastos.vue',
    'RptEmisionLaser.vue',
    'RptFacturaEmision.vue',
    'RptFacturaEnergia.vue',
    'RptMercados.vue',
    'RptMovimientos.vue'
];

$basePath = 'RefactorX/FrontEnd/src/views/modules/mercados/';

foreach ($components as $component) {
    $file = $basePath . $component;
    if (file_exists($file)) {
        $content = file_get_contents($file);
        
        // Find all Operacion patterns
        preg_match_all('/Operacion:\s*[\'"]([^\'"\s]+)[\'"]/', $content, $matches);
        
        if (!empty($matches[1])) {
            $sps = array_unique($matches[1]);
            echo "$component:\n";
            foreach ($sps as $sp) {
                echo "  - $sp\n";
            }
            echo "\n";
        }
    }
}
?>
