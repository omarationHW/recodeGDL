<?php
/**
 * Script para aplicar municipal-theme.css y module-view pattern a componentes Rpt*.vue
 */

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
echo " APLICANDO MUNICIPAL-THEME.CSS Y MODULE-VIEW PATTERN\n";
echo "═══════════════════════════════════════════════════════════════\n\n";

$totalProcessed = 0;
$totalErrors = 0;

foreach ($components as $comp) {
    $filePath = $basePath . $comp;

    if (!file_exists($filePath)) {
        echo "❌ $comp - No existe\n";
        $totalErrors++;
        continue;
    }

    $content = file_get_contents($filePath);
    $originalContent = $content;
    $changes = [];

    // 1. Agregar import de municipal-theme si no existe
    if (strpos($content, 'municipal-theme.css') === false) {
        // Buscar el <style> tag y agregar import
        if (preg_match('/<style[^>]*>/', $content, $matches, PREG_OFFSET_CAPTURE)) {
            $stylePos = $matches[0][1] + strlen($matches[0][0]);
            $content = substr_replace(
                $content,
                "\n@import '@/styles/municipal-theme.css';",
                $stylePos,
                0
            );
            $changes[] = "✓ Added municipal-theme.css import";
        } else {
            // Si no hay tag <style>, agregarlo al final antes de </template>
            if (strpos($content, '</script>') !== false) {
                $content = str_replace(
                    '</script>',
                    "</script>\n\n<style src=\"@/styles/municipal-theme.css\"></style>",
                    $content
                );
                $changes[] = "✓ Added <style> tag with municipal-theme.css";
            }
        }
    }

    // 2. Reemplazar clases Bootstrap por municipal-theme
    $replacements = [
        // Contenedores
        ['/<div class="container-fluid/', '<div class="module-view'],

        // Cards
        ['/<div class="card\s/', '<div class="municipal-card '],
        ['/<div class="card-header\s/', '<div class="municipal-card-header '],
        ['/<div class="card-body\s/', '<div class="municipal-card-body '],
        ['/class="card"/', 'class="municipal-card"'],
        ['/class="card-header"/', 'class="municipal-card-header"'],
        ['/class="card-body"/', 'class="municipal-card-body"'],

        // Forms
        ['/class="form-control"/', 'class="municipal-form-control"'],
        ['/class="form-select"/', 'class="municipal-form-control"'],
        ['/class="form-label"/', 'class="municipal-form-label"'],

        // Buttons
        ['/class="btn btn-primary"/', 'class="btn-municipal-primary"'],
        ['/class="btn btn-success"/', 'class="btn-municipal-success"'],
        ['/class="btn btn-secondary"/', 'class="btn-municipal-secondary"'],
        ['/class="btn btn-danger"/', 'class="btn-municipal-danger"'],
        ['/class="btn btn-warning"/', 'class="btn-municipal-warning"'],

        // Tables
        ['/class="table\s/', 'class="municipal-table '],
        ['/class="table"/', 'class="municipal-table"'],

        // Badges
        ['/class="badge bg-primary"/', 'class="badge-primary"'],
        ['/class="badge bg-success"/', 'class="badge-success"'],
        ['/class="badge bg-warning"/', 'class="badge-warning"'],
        ['/class="badge bg-danger"/', 'class="badge-danger"'],
        ['/class="badge bg-info"/', 'class="badge-info"'],
    ];

    $replaceCount = 0;
    foreach ($replacements as list($pattern, $replacement)) {
        $newContent = preg_replace($pattern, $replacement, $content, -1, $count);
        if ($count > 0) {
            $content = $newContent;
            $replaceCount += $count;
        }
    }

    if ($replaceCount > 0) {
        $changes[] = "✓ Replaced $replaceCount Bootstrap classes with municipal-theme";
    }

    // Guardar cambios
    if ($content !== $originalContent) {
        file_put_contents($filePath, $content);
        echo "✅ $comp\n";
        foreach ($changes as $change) {
            echo "   $change\n";
        }
        $totalProcessed++;
    } else {
        echo "⚪ $comp - No changes needed\n";
    }

    echo "\n";
}

echo "═══════════════════════════════════════════════════════════════\n";
echo " RESUMEN\n";
echo "═══════════════════════════════════════════════════════════════\n\n";
echo "Componentes procesados: $totalProcessed\n";
echo "Errores: $totalErrors\n";
echo "\n✅ Proceso completado\n\n";
