<?php
/**
 * Test del SP sp_get_mercados_by_recaudadora desde Laravel
 * Simula exactamente cómo GenericController llama al SP
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

// Bootstrap Laravel
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== Test de sp_get_mercados_by_recaudadora ===" . PHP_EOL . PHP_EOL;

try {
    // Probar con diferentes recaudadoras
    $recaudadoras = [1, 2, 3];

    foreach ($recaudadoras as $recId) {
        echo "Probando recaudadora ID: $recId" . PHP_EOL;

        // Llamar al SP exactamente como lo hace GenericController
        $results = DB::connection('padron_licencias')
            ->select("SELECT * FROM sp_get_mercados_by_recaudadora(?)", [$recId]);

        echo "  Mercados encontrados: " . count($results) . PHP_EOL;

        if (count($results) > 0) {
            echo "  Primeros 2 mercados:" . PHP_EOL;
            foreach (array_slice($results, 0, 2) as $mercado) {
                echo "    - ID: {$mercado->num_mercado_nvo}, Nombre: {$mercado->descripcion}" . PHP_EOL;
            }
        }

        echo PHP_EOL;
    }

    echo "✅ ÉXITO: SP funciona correctamente desde Laravel" . PHP_EOL;
    echo "El componente PadronEnergia debería funcionar ahora." . PHP_EOL;

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . PHP_EOL;
    echo PHP_EOL;
    echo "Stack trace:" . PHP_EOL;
    echo $e->getTraceAsString() . PHP_EOL;
    exit(1);
}
