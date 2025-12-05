<?php

require __DIR__ . '/vendor/autoload.php';

use Illuminate\Support\Facades\DB;

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "📦 Desplegando SP recaudadora_sdosfavor_dm...\n\n";

try {
    $sql = file_get_contents(__DIR__ . '/recaudadora_sdosfavor_dm.sql');

    DB::connection('pgsql')->unprepared($sql);

    echo "✅ SP creado exitosamente\n\n";

    // Probar el SP con los ejemplos
    echo "🧪 Probando SP con datos reales...\n\n";

    $testCuentas = ['539853', '531606', '531445'];

    foreach ($testCuentas as $cuenta) {
        try {
            $result = DB::connection('pgsql')->select("
                SELECT * FROM recaudadora_sdosfavor_dm(?)
            ", [$cuenta]);

            if (count($result) > 0) {
                $r = $result[0];
                echo "✓ Cuenta {$cuenta}:\n";
                echo "  Folio: {$r->folio}\n";
                echo "  Saldo Inicial: $" . number_format($r->saldo_inicial, 2) . "\n";
                echo "  Importe Aplicado: $" . number_format($r->importe_aplicado, 2) . "\n";
                echo "  Saldo Restante: $" . number_format($r->saldo_restante, 2) . "\n";
                echo "  Estado: {$r->estado}\n";
                echo "  Fecha Alta: {$r->fecha_alta}\n";
                echo "\n";
            } else {
                echo "✗ Cuenta {$cuenta}: Sin resultados\n\n";
            }
        } catch (Exception $e) {
            echo "✗ Error con cuenta {$cuenta}: " . $e->getMessage() . "\n\n";
        }
    }

    // Probar sin filtro
    echo "🧪 Probando SP sin filtro (todos los registros)...\n\n";

    $all = DB::connection('pgsql')->select("
        SELECT COUNT(*) as total FROM recaudadora_sdosfavor_dm('')
    ");

    echo "✓ Total de registros retornados: {$all[0]->total}\n\n";

    echo "╔════════════════════════════════════════════════════════════╗\n";
    echo "║                  🎉 DESPLIEGUE EXITOSO 🎉                  ║\n";
    echo "╚════════════════════════════════════════════════════════════╝\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
