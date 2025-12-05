<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sfrm_calificacionqr...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sfrm_calificacionqr.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    // Probar el SP con los ejemplos
    echo "🧪 Probando SP con datos reales...\n\n";

    $testData = [
        ['cuenta' => '415267', 'folio' => null],
        ['cuenta' => '415266', 'folio' => null],
        ['cuenta' => null, 'folio' => '7048']
    ];

    foreach ($testData as $idx => $test) {
        $label = $test['cuenta'] ? "cuenta {$test['cuenta']}" : "folio {$test['folio']}";

        try {
            $result = DB::connection('pgsql')->select("
                SELECT * FROM recaudadora_sfrm_calificacionqr(?, ?)
            ", [$test['cuenta'], $test['folio']]);

            if (count($result) > 0) {
                $r = $result[0];
                echo "✓ Prueba con {$label}:\n";
                echo "  ID Multa: {$r->id_multa}\n";
                echo "  Folio: {$r->folio}\n";
                echo "  Contribuyente: {$r->contribuyente}\n";
                echo "  Calificación: $" . number_format($r->calificacion, 2) . "\n";
                echo "  Tipo: {$r->tipo_calificacion_desc} ({$r->tipo_calificacion_cod})\n";
                echo "  Usuario: {$r->usuario_calificacion}\n";
                echo "  Fecha: {$r->fecha_calificacion}\n";
                echo "\n";
            } else {
                echo "✗ Prueba con {$label}: Sin resultados\n\n";
            }
        } catch (Exception $e) {
            echo "✗ Error con {$label}: " . $e->getMessage() . "\n\n";
        }
    }

    // Probar sin filtro
    echo "🧪 Probando SP sin filtros (primeros registros)...\n\n";

    $all = DB::connection('pgsql')->select("
        SELECT COUNT(*) as total FROM recaudadora_sfrm_calificacionqr('', '')
    ");

    echo "✓ Total de registros retornados: {$all[0]->total}\n\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║                  🎉 DESPLIEGUE EXITOSO 🎉                  ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
