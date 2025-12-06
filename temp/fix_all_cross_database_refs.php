<?php
/**
 * Corrige automáticamente referencias cross-database en todos los SPs
 * Patrón: padron_licencias.schema.table → schema.table
 * Patrón: mercados.schema.table → schema.table
 */

// Lista de componentes con referencias cross-database detectadas
$components_with_issues = [
    'Prescripcion' => 2,
    'RptFacturaGLunes' => 3,
    'RptLocalesGiro' => 2,
    'RptIngresos' => 2,
    'RptIngresosEnergia' => 3,
    'RptPagosAno' => 3,
    'RptPagosCaja' => 3,
    'RptPagosDetalle' => 3,
    'RptPagosGrl' => 2
];

$base_sql_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\';
$backup_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\temp\\backup_sql\\';

// Create backup directory
if (!is_dir($backup_path)) {
    mkdir($backup_path, 0777, true);
}

$report = [];
$totalFixed = 0;

foreach (array_keys($components_with_issues) as $comp_name) {
    $sql_files = glob($base_sql_path . $comp_name . '_*.sql');

    foreach ($sql_files as $sql_file) {
        $filename = basename($sql_file);
        $content = file_get_contents($sql_file);
        $original_content = $content;

        // Backup original
        copy($sql_file, $backup_path . $filename);

        // Count occurrences BEFORE fixing
        preg_match_all('/(padron_licencias|mercados)\.(comun|public|publico)\.([a-z_0-9]+)/i', $content, $matches_before);
        $count_before = count($matches_before[0]);

        // Apply fixes
        $patterns = [
            // padron_licencias.comun.table → publico.table
            '/padron_licencias\.comun\.([a-z_0-9]+)/i' => 'publico.$1',

            // padron_licencias.public.table → public.table
            '/padron_licencias\.public\.([a-z_0-9]+)/i' => 'public.$1',

            // padron_licencias.publico.table → publico.table
            '/padron_licencias\.publico\.([a-z_0-9]+)/i' => 'publico.$1',

            // mercados.public.table → public.table
            '/mercados\.public\.([a-z_0-9]+)/i' => 'public.$1',

            // mercados.publico.table → publico.table
            '/mercados\.publico\.([a-z_0-9]+)/i' => 'publico.$1',

            // mercados.comun.table → publico.table (aunque esto no debería existir)
            '/mercados\.comun\.([a-z_0-9]+)/i' => 'publico.$1'
        ];

        foreach ($patterns as $pattern => $replacement) {
            $content = preg_replace($pattern, $replacement, $content);
        }

        // Count occurrences AFTER fixing
        preg_match_all('/(padron_licencias|mercados)\.(comun|public|publico)\.([a-z_0-9]+)/i', $content, $matches_after);
        $count_after = count($matches_after[0]);

        $fixed_count = $count_before - $count_after;

        if ($fixed_count > 0) {
            // Save fixed content
            file_put_contents($sql_file, $content);
            $totalFixed++;

            $report[] = [
                'component' => $comp_name,
                'file' => $filename,
                'refs_before' => $count_before,
                'refs_after' => $count_after,
                'fixed' => $fixed_count,
                'status' => '✅ CORREGIDO'
            ];
        } else if ($count_before > 0 && $count_after > 0) {
            // Still has issues after fix
            $report[] = [
                'component' => $comp_name,
                'file' => $filename,
                'refs_before' => $count_before,
                'refs_after' => $count_after,
                'fixed' => 0,
                'status' => '⚠️  REVISIÓN MANUAL'
            ];
        }
    }
}

// Generate report
echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  CORRECCIÓN MASIVA: Referencias Cross-Database                           ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

foreach ($report as $r) {
    echo "{$r['status']} {$r['component']}/{$r['file']}\n";
    echo "  Referencias antes: {$r['refs_before']}\n";
    echo "  Referencias después: {$r['refs_after']}\n";
    echo "  Corregidas: {$r['fixed']}\n\n";
}

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  RESUMEN                                                                  ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

echo "  Archivos corregidos: $totalFixed\n";
echo "  Backups guardados en: temp/backup_sql/\n\n";

// Patrones aplicados
echo "📝 Patrones de corrección aplicados:\n\n";
foreach ($patterns as $pattern => $replacement) {
    echo "  • $pattern → $replacement\n";
}

echo "\n✅ Proceso completado\n";
?>
