<?php
/**
 * Analiza todos los componentes pendientes marcados con "---"
 * Verifica configuración de Base en Vue y referencias cross-database en SPs
 */

$components = [
    ['name' => 'Estadisticas', 'sp' => 'sp_estadistica_pagos_adeudos', 'path' => 'estadisticas'],
    ['name' => 'EnergiaModif', 'sp' => 'sp_energia_modif_*', 'path' => 'energia-modif'],
    ['name' => 'Prescripcion', 'sp' => 'sp_listar_*', 'path' => 'prescripcion'],
    ['name' => 'RptEmisionRbosAbastos', 'sp' => 'sp_rpt_emision_rbos_abastos', 'path' => 'rpt-emision-rbos-abastos'],
    ['name' => 'RptEmisionLaser', 'sp' => 'sp_rpt_emision_laser', 'path' => 'rpt-emision-laser'],
    ['name' => 'RptFacturaEmision', 'sp' => 'sp_rpt_factura_emision', 'path' => 'rpt-factura-emision'],
    ['name' => 'RptFacturaEnergia', 'sp' => 'sp_rpt_factura_energia', 'path' => 'rpt-factura-energia'],
    ['name' => 'RptFacturaGLunes', 'sp' => 'sp_rpt_factura_global', 'path' => 'rpt-factura-glunes'],
    ['name' => 'RptLocalesGiro', 'sp' => 'sp_rpt_locales_giro', 'path' => 'rpt-locales-giro'],
    ['name' => 'RptMercados', 'sp' => 'sp_reporte_catalogo_mercados', 'path' => 'rpt-mercados'],
    ['name' => 'RptMovimientos', 'sp' => 'sp_rpt_movimientos', 'path' => 'rpt-movimientos'],
    ['name' => 'RptIngresos', 'sp' => 'sp_rpt_ingresos_locales', 'path' => 'rpt-ingresos'],
    ['name' => 'RptIngresosEnergia', 'sp' => 'sp_rpt_ingresos_energia', 'path' => 'rpt-ingresos-energia'],
    ['name' => 'RptPagosAno', 'sp' => 'sp_rpt_pagos_ano', 'path' => 'rpt-pagos-ano'],
    ['name' => 'RptPagosCaja', 'sp' => 'sp_rpt_pagos_caja', 'path' => 'rpt-pagos-caja'],
    ['name' => 'RptPagosDetalle', 'sp' => 'sp_rpt_pagos_detalle', 'path' => 'rpt-pagos-detalle'],
    ['name' => 'RptPagosGrl', 'sp' => 'sp_rpt_pagos_grl', 'path' => 'rpt-pagos-grl']
];

$base_vue_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\FrontEnd\\src\\views\\modules\\mercados\\';
$base_sql_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\';

$report = [];

foreach ($components as $comp) {
    $vue_file = $base_vue_path . $comp['name'] . '.vue';
    $sql_files = glob($base_sql_path . $comp['name'] . '_*.sql');

    $result = [
        'component' => $comp['name'],
        'sp_name' => $comp['sp'],
        'vue_exists' => file_exists($vue_file),
        'vue_base' => null,
        'sql_files' => count($sql_files),
        'cross_db_refs' => [],
        'issues' => []
    ];

    // Check Vue file
    if ($result['vue_exists']) {
        $vue_content = file_get_contents($vue_file);

        // Extract Base configuration
        if (preg_match_all('/Base:\s*[\'"]([^\'"]+)[\'"]/', $vue_content, $matches)) {
            $result['vue_base'] = array_unique($matches[1]);

            // Check if using padron_licencias
            foreach ($result['vue_base'] as $base) {
                if ($base === 'padron_licencias') {
                    $result['issues'][] = "Vue usa Base: 'padron_licencias' (verificar si debería ser 'mercados')";
                }
            }
        } else {
            $result['issues'][] = "No se encontró configuración de Base en Vue";
        }
    } else {
        $result['issues'][] = "Archivo Vue NO EXISTE";
    }

    // Check SQL files
    foreach ($sql_files as $sql_file) {
        $sql_content = file_get_contents($sql_file);

        // Check for cross-database references
        if (preg_match_all('/(padron_licencias|mercados)\.(comun|public|publico)\.([a-z_0-9]+)/i', $sql_content, $matches, PREG_SET_ORDER)) {
            foreach ($matches as $match) {
                $result['cross_db_refs'][] = [
                    'file' => basename($sql_file),
                    'ref' => $match[0],
                    'database' => $match[1],
                    'schema' => $match[2],
                    'table' => $match[3]
                ];
            }
        }
    }

    if (count($result['cross_db_refs']) > 0) {
        $result['issues'][] = count($result['cross_db_refs']) . " referencias cross-database encontradas en SQL";
    }

    if ($result['sql_files'] === 0) {
        $result['issues'][] = "NO se encontraron archivos SQL";
    }

    $report[] = $result;
}

// Generate report
echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  ANÁLISIS MASIVO: Componentes Marcados con ---                           ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

$total = count($components);
$with_issues = 0;

foreach ($report as $r) {
    $has_issues = count($r['issues']) > 0 || count($r['cross_db_refs']) > 0;
    if ($has_issues) $with_issues++;

    $status_icon = $has_issues ? "⚠️ " : "✅";
    echo "$status_icon {$r['component']}\n";
    echo str_repeat("─", 79) . "\n";

    echo "  Vue File: " . ($r['vue_exists'] ? "✅ Existe" : "❌ NO EXISTE") . "\n";
    if ($r['vue_base']) {
        echo "  Base Config: " . implode(", ", $r['vue_base']) . "\n";
    }
    echo "  SQL Files: {$r['sql_files']} archivo(s)\n";
    echo "  Cross-DB Refs: " . count($r['cross_db_refs']) . "\n";

    if (count($r['issues']) > 0) {
        echo "\n  ⚠️  ISSUES:\n";
        foreach ($r['issues'] as $issue) {
            echo "     • $issue\n";
        }
    }

    if (count($r['cross_db_refs']) > 0 && count($r['cross_db_refs']) <= 10) {
        echo "\n  🔍 Referencias detectadas:\n";
        $unique_refs = array_unique(array_column($r['cross_db_refs'], 'ref'));
        foreach ($unique_refs as $ref) {
            echo "     • $ref\n";
        }
    } elseif (count($r['cross_db_refs']) > 10) {
        echo "\n  🔍 Referencias: (mostrando 5 de " . count($r['cross_db_refs']) . ")\n";
        $unique_refs = array_unique(array_column($r['cross_db_refs'], 'ref'));
        foreach (array_slice($unique_refs, 0, 5) as $ref) {
            echo "     • $ref\n";
        }
    }

    echo "\n";
}

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  RESUMEN                                                                  ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

echo "  Total componentes analizados: $total\n";
echo "  Con issues detectados: $with_issues\n";
echo "  Sin issues: " . ($total - $with_issues) . "\n\n";

// Save detailed report
$json_report = json_encode($report, JSON_PRETTY_PRINT);
file_put_contents('temp/componentes_analisis_detalle.json', $json_report);
echo "📄 Reporte detallado guardado en: temp/componentes_analisis_detalle.json\n";
?>
