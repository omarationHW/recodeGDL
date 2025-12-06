<?php
/**
 * Despliega todos los SPs corregidos a la base de datos mercados
 */

$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

// Lista de componentes cuyos SPs fueron corregidos
$components = [
    'Prescripcion',
    'RptFacturaGLunes',
    'RptLocalesGiro',
    'RptIngresos',
    'RptIngresosEnergia',
    'RptPagosAno',
    'RptPagosCaja',
    'RptPagosDetalle',
    'RptPagosGrl'
];

$base_sql_path = 'C:\\guadalajara\\code\\recodeGDLCurrent\\recodeGDL\\RefactorX\\Base\\mercados\\database\\database\\';

$report = [];
$totalDeployed = 0;
$totalErrors = 0;

foreach ($components as $comp_name) {
    $sql_files = glob($base_sql_path . $comp_name . '_*.sql');

    foreach ($sql_files as $sql_file) {
        $filename = basename($sql_file);
        $sql_content = file_get_contents($sql_file);

        try {
            $pdo->exec($sql_content);
            $totalDeployed++;

            $report[] = [
                'component' => $comp_name,
                'file' => $filename,
                'status' => '✅ DESPLEGADO',
                'error' => null
            ];
        } catch (PDOException $e) {
            $totalErrors++;

            $report[] = [
                'component' => $comp_name,
                'file' => $filename,
                'status' => '❌ ERROR',
                'error' => $e->getMessage()
            ];
        }
    }
}

// Generate report
echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  DESPLIEGUE MASIVO: SPs Corregidos                                       ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

foreach ($report as $r) {
    echo "{$r['status']} {$r['component']}/{$r['file']}\n";
    if ($r['error']) {
        $error_short = substr($r['error'], 0, 100);
        echo "  Error: $error_short" . (strlen($r['error']) > 100 ? '...' : '') . "\n";
    }
    echo "\n";
}

echo "╔═══════════════════════════════════════════════════════════════════════════╗\n";
echo "║  RESUMEN                                                                  ║\n";
echo "╚═══════════════════════════════════════════════════════════════════════════╝\n\n";

echo "  SPs desplegados exitosamente: $totalDeployed\n";
echo "  Errores encontrados: $totalErrors\n\n";

if ($totalErrors === 0) {
    echo "✅ TODOS LOS SPs DESPLEGADOS CORRECTAMENTE\n";
} else {
    echo "⚠️  Algunos SPs requieren revisión manual\n";
}
?>
