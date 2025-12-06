<?php
/**
 * ANÁLISIS: AppSidebar.vue - Solo Sección MERCADOS
 * Analiza únicamente los labels dentro del módulo Mercados
 */

$file = __DIR__ . '/../RefactorX/FrontEnd/src/components/layout/AppSidebar.vue';

if (!file_exists($file)) {
    die("ERROR: No se encuentra el archivo AppSidebar.vue\n");
}

$content = file_get_contents($file);

echo "========================================\n";
echo "ANÁLISIS: Sección MERCADOS - AppSidebar\n";
echo "========================================\n\n";

// Extraer la sección de Mercados
// Buscar desde "label: 'Mercados'" hasta el siguiente bloque principal
preg_match("/\{\s*label:\s*['\"]Mercados['\"](.*?)(?=\n\s*\},?\s*\n\s*\{[^{]*label:|\}\s*\]\s*\})/s", $content, $mercados_section);

if (!isset($mercados_section[1])) {
    die("ERROR: No se pudo extraer la sección de Mercados\n");
}

$mercados_content = $mercados_section[1];

// Extraer todos los labels de la sección Mercados
preg_match_all("/label:\s*['\"]([^'\"]+)['\"]/", $mercados_content, $matches);

$labels = $matches[1];

echo "Total de items en Mercados: " . count($labels) . "\n";
echo str_repeat("=", 60) . "\n\n";

// Categorizar los labels
$categorias = [
    'con_asterisco_simple' => [],         // '* Label'
    'con_dos_asteriscos' => [],           // '** Label'
    'con_tres_asteriscos' => [],          // '*** Label'
    'con_guion_simple' => [],             // '- Label' o '-  Label'
    'con_dos_guiones' => [],              // '-- Label'
    'con_asterisco_guion' => [],          // '*/-' o similar
    'sin_marcador' => []                  // 'Label'
];

foreach ($labels as $label) {
    $label_trim = trim($label);

    // Categorizar según el marcador
    if (preg_match('/^\*\*\*\s+/', $label_trim)) {
        $categorias['con_tres_asteriscos'][] = $label;
    } elseif (preg_match('/^\*\*\s+/', $label_trim)) {
        $categorias['con_dos_asteriscos'][] = $label;
    } elseif (preg_match('/^\*\s+/', $label_trim) || preg_match('/^\*\s*[^\*\s]/', $label_trim)) {
        $categorias['con_asterisco_simple'][] = $label;
    } elseif (preg_match('/^--\s+/', $label_trim)) {
        $categorias['con_dos_guiones'][] = $label;
    } elseif (preg_match('/^-\s+/', $label_trim) || preg_match('/^-\s*[^-\s]/', $label_trim)) {
        $categorias['con_guion_simple'][] = $label;
    } elseif (preg_match('/\*\//', $label_trim) || preg_match('/\*\s*-/', $label_trim)) {
        $categorias['con_asterisco_guion'][] = $label;
    } else {
        // Verificar que no empiece con asterisco o guion
        if (!preg_match('/^[\*\-]/', $label_trim)) {
            $categorias['sin_marcador'][] = $label;
        }
    }
}

// Mostrar resumen
echo "RESUMEN DE MARCADORES EN MERCADOS:\n";
echo str_repeat("=", 60) . "\n\n";

$total_con_marcador = 0;
$total_sin_marcador = count($categorias['sin_marcador']);
$total_general = count($labels);

echo sprintf("%-35s | %4s\n", "TIPO", "QTY");
echo str_repeat("-", 60) . "\n";

foreach ($categorias as $tipo => $items) {
    $count = count($items);
    if ($tipo !== 'sin_marcador' && $count > 0) {
        $total_con_marcador += $count;
    }

    $nombre_categoria = str_replace('_', ' ', ucwords($tipo, '_'));
    echo sprintf("%-35s | %4d\n", $nombre_categoria, $count);
}

echo str_repeat("-", 60) . "\n";
echo sprintf("%-35s | %4d\n", "TOTAL CON MARCADOR", $total_con_marcador);
echo sprintf("%-35s | %4d\n", "TOTAL SIN MARCADOR", $total_sin_marcador);
echo sprintf("%-35s | %4d\n", "TOTAL GENERAL", $total_general);

// Detalles por categoría
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "DETALLE POR CATEGORÍA\n";
echo str_repeat("=", 60) . "\n";

foreach ($categorias as $tipo => $items) {
    if (count($items) > 0) {
        $nombre_categoria = str_replace('_', ' ', strtoupper($tipo));
        echo "\n┌─ $nombre_categoria (" . count($items) . ") ─┐\n";
        foreach ($items as $idx => $label) {
            echo sprintf("│ %3d. %s\n", $idx + 1, $label);
        }
        echo "└" . str_repeat("─", 58) . "┘\n";
    }
}

// Buscar específicamente patrones con */-
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "BÚSQUEDA ESPECÍFICA: Patrones con '*/-' o '* -'\n";
echo str_repeat("=", 60) . "\n\n";

$patrones_especiales = [];
foreach ($labels as $label) {
    if (preg_match('/\*\s*[\/\-]/', $label) || preg_match('/\*\s+-/', $label)) {
        $patrones_especiales[] = $label;
    }
}

if (count($patrones_especiales) > 0) {
    echo "✓ Se encontraron " . count($patrones_especiales) . " labels con patrón '*/-' o similar:\n\n";
    foreach ($patrones_especiales as $idx => $label) {
        echo sprintf("%3d. '%s'\n", $idx + 1, $label);
    }
} else {
    echo "❌ NO se encontraron labels con el patrón '*/-' o '* -'\n";
}

// Comparar paths con labels
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "RELACIÓN PATH → LABEL\n";
echo str_repeat("=", 60) . "\n\n";

// Extraer paths y labels juntos
preg_match_all("/path:\s*['\"]([^'\"]+)['\"].*?label:\s*['\"]([^'\"]+)['\"]/s", $mercados_content, $path_label_matches, PREG_SET_ORDER);

echo sprintf("%-40s | %s\n", "PATH", "LABEL");
echo str_repeat("-", 100) . "\n";

$marcados = [];
foreach ($path_label_matches as $match) {
    $path = $match[1];
    $label = $match[2];

    // Determinar el marcador
    $marcador = 'NINGUNO';
    if (preg_match('/^\*\*\*\s+/', trim($label))) {
        $marcador = '***';
    } elseif (preg_match('/^\*\*\s+/', trim($label))) {
        $marcador = '**';
    } elseif (preg_match('/^\*\s+/', trim($label))) {
        $marcador = '*';
    } elseif (preg_match('/^--\s+/', trim($label))) {
        $marcador = '--';
    } elseif (preg_match('/^-\s+/', trim($label))) {
        $marcador = '-';
    }

    if (!isset($marcados[$marcador])) {
        $marcados[$marcador] = [];
    }
    $marcados[$marcador][] = ['path' => $path, 'label' => $label];
}

// Mostrar agrupados por marcador
foreach (['***', '**', '*', '--', '-', 'NINGUNO'] as $marc) {
    if (isset($marcados[$marc]) && count($marcados[$marc]) > 0) {
        echo "\n▼ CON MARCADOR [$marc] (" . count($marcados[$marc]) . " items) ▼\n";
        echo str_repeat("-", 100) . "\n";
        foreach ($marcados[$marc] as $item) {
            $path_corto = str_replace('/mercados/', '', $item['path']);
            echo sprintf("%-40s → %s\n", $path_corto, $item['label']);
        }
    }
}

echo "\n========================================\n";
echo "ANÁLISIS COMPLETADO\n";
echo "========================================\n";
