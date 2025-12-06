<?php
/**
 * ANÁLISIS: AppSidebar.vue - Marcadores en Labels
 * Cuenta cuántos labels tienen cada tipo de marcador
 */

$file = __DIR__ . '/../RefactorX/FrontEnd/src/components/layout/AppSidebar.vue';

if (!file_exists($file)) {
    die("ERROR: No se encuentra el archivo AppSidebar.vue\n");
}

$content = file_get_contents($file);

// Buscar todas las líneas que contienen label:
preg_match_all("/label:\s*['\"]([^'\"]+)['\"]/", $content, $matches);

$labels = $matches[1];

echo "========================================\n";
echo "ANÁLISIS: AppSidebar.vue - Marcadores\n";
echo "========================================\n\n";

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
    // Limpiar espacios iniciales/finales
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
    } elseif (preg_match('/\*\//', $label_trim)) {
        $categorias['con_asterisco_guion'][] = $label;
    } else {
        // Verificar que no empiece con asterisco o guion
        if (!preg_match('/^[\*\-]/', $label_trim)) {
            $categorias['sin_marcador'][] = $label;
        }
    }
}

// Mostrar resultados
echo "RESUMEN DE MARCADORES:\n";
echo str_repeat("=", 60) . "\n\n";

$total_con_marcador = 0;
$total_sin_marcador = count($categorias['sin_marcador']);
$total_general = count($labels);

foreach ($categorias as $tipo => $items) {
    $count = count($items);
    if ($tipo !== 'sin_marcador' && $count > 0) {
        $total_con_marcador += $count;
    }

    $nombre_categoria = str_replace('_', ' ', ucwords($tipo, '_'));
    echo sprintf("%-30s: %3d items\n", $nombre_categoria, $count);
}

echo str_repeat("-", 60) . "\n";
echo sprintf("%-30s: %3d items\n", "TOTAL CON MARCADOR", $total_con_marcador);
echo sprintf("%-30s: %3d items\n", "TOTAL SIN MARCADOR", $total_sin_marcador);
echo sprintf("%-30s: %3d items\n", "TOTAL GENERAL", $total_general);

// Detalles por categoría
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "DETALLE POR CATEGORÍA\n";
echo str_repeat("=", 60) . "\n\n";

foreach ($categorias as $tipo => $items) {
    if (count($items) > 0) {
        $nombre_categoria = str_replace('_', ' ', strtoupper($tipo));
        echo "\n--- $nombre_categoria (" . count($items) . ") ---\n";
        foreach ($items as $idx => $label) {
            echo sprintf("%3d. %s\n", $idx + 1, $label);
        }
    }
}

// Buscar específicamente patrones con */-
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "BÚSQUEDA ESPECÍFICA: Patrones con '*/-'\n";
echo str_repeat("=", 60) . "\n\n";

$patrones_especiales = [];
foreach ($labels as $label) {
    if (strpos($label, '*/-') !== false || strpos($label, '* /') !== false) {
        $patrones_especiales[] = $label;
    }
}

if (count($patrones_especiales) > 0) {
    echo "Se encontraron " . count($patrones_especiales) . " labels con patrón '*/-':\n\n";
    foreach ($patrones_especiales as $idx => $label) {
        echo sprintf("%3d. %s\n", $idx + 1, $label);
    }
} else {
    echo "❌ NO se encontraron labels con el patrón '*/-'\n";
}

// Análisis de módulo Mercados
echo "\n\n" . str_repeat("=", 60) . "\n";
echo "ANÁLISIS: Módulo Mercados\n";
echo str_repeat("=", 60) . "\n\n";

// Extraer solo la sección de Mercados
preg_match("/label:\s*['\"]Mercados['\"](.*?)(?=label:\s*['\"][^'\"]*['\"],\s*icon:|$)/s", $content, $mercados_section);

if (isset($mercados_section[1])) {
    preg_match_all("/label:\s*['\"]([^'\"]+)['\"]/", $mercados_section[1], $mercados_matches);
    $mercados_labels = $mercados_matches[1];

    $mercados_con_asterisco = 0;
    $mercados_con_guion = 0;
    $mercados_sin_marcador = 0;
    $mercados_tres_asteriscos = 0;

    foreach ($mercados_labels as $label) {
        $label_trim = trim($label);
        if (preg_match('/^\*\*\*\s+/', $label_trim)) {
            $mercados_tres_asteriscos++;
        } elseif (preg_match('/^\*\s+/', $label_trim)) {
            $mercados_con_asterisco++;
        } elseif (preg_match('/^-+\s+/', $label_trim)) {
            $mercados_con_guion++;
        } elseif (!preg_match('/^[\*\-]/', $label_trim)) {
            $mercados_sin_marcador++;
        }
    }

    echo "Módulo Mercados:\n";
    echo sprintf("  - Con * (asterisco simple): %d\n", $mercados_con_asterisco);
    echo sprintf("  - Con *** (tres asteriscos): %d\n", $mercados_tres_asteriscos);
    echo sprintf("  - Con - o -- (guiones): %d\n", $mercados_con_guion);
    echo sprintf("  - Sin marcador: %d\n", $mercados_sin_marcador);
    echo sprintf("  - Total en Mercados: %d\n", count($mercados_labels));
}

echo "\n========================================\n";
echo "ANÁLISIS COMPLETADO\n";
echo "========================================\n";
