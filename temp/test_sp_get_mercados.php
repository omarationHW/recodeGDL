<?php
/**
 * Test: Verificar sp_get_mercados con parámetro p_oficina
 */

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "PRUEBA: sp_get_mercados\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    // Verificar si existe el SP con parámetro
    echo "1. Verificando si existe sp_get_mercados con parámetro...\n";
    $verify = DB::connection($connection)->select("
        SELECT
            p.proname AS nombre_funcion,
            pg_get_function_arguments(p.oid) AS parametros,
            pg_get_function_result(p.oid) AS resultado
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_get_mercados'
        ORDER BY p.oid DESC
    ");

    if (!empty($verify)) {
        foreach ($verify as $idx => $func) {
            echo "   Versión " . ($idx + 1) . ":\n";
            echo "   - Función: {$func->nombre_funcion}\n";
            echo "   - Parámetros: {$func->parametros}\n";
            echo "   - Resultado: {$func->resultado}\n\n";
        }
    } else {
        echo "   ✗ No se encontró el SP\n\n";
    }

    // Obtener una recaudadora de prueba
    echo "2. Obteniendo recaudadora de prueba...\n";
    $testOficina = DB::connection($connection)->select("
        SELECT DISTINCT oficina
        FROM ta_11_mercados
        WHERE oficina IS NOT NULL
        LIMIT 1
    ");

    if (empty($testOficina)) {
        throw new Exception("No hay datos de prueba en ta_11_mercados");
    }

    $oficina = $testOficina[0]->oficina;
    echo "   ✓ Oficina de prueba: $oficina\n\n";

    // Probar el SP con parámetro
    echo "3. Probando sp_get_mercados con p_oficina=$oficina...\n";
    try {
        $result = DB::connection($connection)->select("
            SELECT * FROM sp_get_mercados($oficina)
        ");

        if (!empty($result)) {
            echo "   ✓ SP ejecutado exitosamente\n";
            echo "   ✓ Mercados encontrados: " . count($result) . "\n";
            if (count($result) > 0) {
                $merc = $result[0];
                echo "   ✓ Primer mercado:\n";
                echo "     - num_mercado_nvo: " . ($merc->num_mercado_nvo ?? 'N/A') . "\n";
                echo "     - categoria: " . ($merc->categoria ?? 'N/A') . "\n";
                echo "     - descripcion: " . ($merc->descripcion ?? 'N/A') . "\n";
            }
        } else {
            echo "   ⚠ No se encontraron mercados para la oficina $oficina\n";
        }
    } catch (Exception $e) {
        echo "   ✗ Error al ejecutar SP: " . $e->getMessage() . "\n";
        echo "   Intentando desplegar la versión correcta...\n\n";

        // Desplegar la versión con parámetro
        $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/CargaPagMercado_sp_get_mercados.sql';
        if (file_exists($sqlFile)) {
            $sql = file_get_contents($sqlFile);
            DB::connection($connection)->unprepared($sql);
            echo "   ✓ SP desplegado desde: CargaPagMercado_sp_get_mercados.sql\n\n";

            // Reintentar
            echo "4. Reintentando prueba...\n";
            $result = DB::connection($connection)->select("
                SELECT * FROM sp_get_mercados($oficina)
            ");

            if (!empty($result)) {
                echo "   ✓ SP ejecutado exitosamente después del despliegue\n";
                echo "   ✓ Mercados encontrados: " . count($result) . "\n";
            }
        }
    }

    echo "\n==============================================\n";
    echo "✓ PRUEBA COMPLETADA\n";
    echo "==============================================\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
