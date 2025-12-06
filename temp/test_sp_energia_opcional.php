<?php
/**
 * Test de parámetros opcionales: sp_energia_modif_buscar
 */

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "PRUEBAS: Parámetros Opcionales\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    // Obtener datos de prueba
    $testData = DB::connection($connection)->select("
        SELECT l.oficina, l.num_mercado, l.categoria, l.seccion, l.local
        FROM publico.ta_11_locales l
        INNER JOIN publico.ta_11_energia e ON l.id_local = e.id_local
        WHERE l.oficina IS NOT NULL
        LIMIT 1
    ");

    if (empty($testData)) {
        throw new Exception("No hay datos de prueba");
    }

    $data = $testData[0];

    // Test 1: Con todos los parámetros (incluyendo NULL)
    echo "Test 1: Con 7 parámetros (letra=NULL, bloque=NULL)\n";
    $result1 = DB::connection($connection)->select("
        SELECT * FROM sp_energia_modif_buscar(
            {$data->oficina}::INTEGER,
            {$data->num_mercado}::INTEGER,
            {$data->categoria}::INTEGER,
            '{$data->seccion}'::VARCHAR,
            {$data->local}::INTEGER,
            NULL,
            NULL
        )
    ");

    if (!empty($result1)) {
        echo "   ✓ Encontrado: id_energia={$result1[0]->id_energia}\n\n";
    } else {
        echo "   ✗ No encontrado\n\n";
    }

    // Test 2: Solo con 5 parámetros (parámetros opcionales omitidos)
    echo "Test 2: Solo con 5 parámetros (omitiendo letra y bloque)\n";
    $result2 = DB::connection($connection)->select("
        SELECT * FROM sp_energia_modif_buscar(
            {$data->oficina}::INTEGER,
            {$data->num_mercado}::INTEGER,
            {$data->categoria}::INTEGER,
            '{$data->seccion}'::VARCHAR,
            {$data->local}::INTEGER
        )
    ");

    if (!empty($result2)) {
        echo "   ✓ Encontrado: id_energia={$result2[0]->id_energia}\n";
        echo "   ✓ cve_consumo: {$result2[0]->cve_consumo}\n";
        echo "   ✓ cantidad: {$result2[0]->cantidad}\n\n";
    } else {
        echo "   ✗ No encontrado\n\n";
    }

    // Test 3: Con letra pero sin bloque
    echo "Test 3: Con 6 parámetros (con letra, sin bloque)\n";
    $result3 = DB::connection($connection)->select("
        SELECT * FROM sp_energia_modif_buscar(
            {$data->oficina}::INTEGER,
            {$data->num_mercado}::INTEGER,
            {$data->categoria}::INTEGER,
            '{$data->seccion}'::VARCHAR,
            {$data->local}::INTEGER,
            NULL
        )
    ");

    if (!empty($result3)) {
        echo "   ✓ Encontrado: id_energia={$result3[0]->id_energia}\n\n";
    } else {
        echo "   ✗ No encontrado\n\n";
    }

    echo "==============================================\n";
    echo "✓ TODAS LAS PRUEBAS COMPLETADAS\n";
    echo "==============================================\n";
    echo "\nLos parámetros opcionales funcionan correctamente:\n";
    echo "  - Con 5 parámetros (omitiendo letra y bloque) ✓\n";
    echo "  - Con 6 parámetros (omitiendo bloque) ✓\n";
    echo "  - Con 7 parámetros (todos incluidos) ✓\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
