<?php
/**
 * Script de despliegue vía Laravel: sp_reporte_catalogo_mercados
 * Fecha: 2025-12-05
 */

// Cambiar al directorio de Laravel
chdir(__DIR__ . '/../RefactorX/BackEnd');

// Incluir el autoloader de Laravel
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

// Cargar la aplicación Laravel
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "DESPLIEGUE VÍA LARAVEL: sp_reporte_catalogo_mercados\n";
echo "==============================================\n\n";

try {
    // Leer el archivo SQL (versión SIMPLE sin JOIN a ta_12_zonas)
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/RptCatalogoMerc_sp_reporte_catalogo_mercados_SIMPLE.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Conectar a mercados (base por defecto)
    $connection = 'pgsql';

    echo "1. Conectando a la base de datos mercados...\n";
    DB::connection($connection)->getPdo();
    echo "   ✓ Conexión establecida\n\n";

    // Eliminar la función anterior (sin parámetros)
    echo "2. Eliminando versión anterior del SP...\n";
    try {
        DB::connection($connection)->statement("DROP FUNCTION IF EXISTS public.sp_reporte_catalogo_mercados();");
        echo "   ✓ SP anterior eliminado\n\n";
    } catch (Exception $e) {
        echo "   ADVERTENCIA: " . $e->getMessage() . "\n\n";
    }

    // Crear la nueva función
    echo "3. Creando nueva versión del SP con parámetros...\n";
    DB::connection($connection)->unprepared($sql);
    echo "   ✓ SP creado correctamente\n\n";

    // Verificar
    echo "4. Verificando el SP...\n";
    $verify = DB::connection($connection)->select("
        SELECT
            p.proname AS nombre_funcion,
            pg_get_function_arguments(p.oid) AS parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_reporte_catalogo_mercados'
        ORDER BY p.oid DESC
        LIMIT 1;
    ");

    if (!empty($verify)) {
        echo "   ✓ Función: " . $verify[0]->nombre_funcion . "\n";
        echo "   ✓ Parámetros: " . $verify[0]->parametros . "\n\n";
    }

    // Probar el SP
    echo "5. Probando el SP...\n\n";

    // Test 1: Sin filtros
    echo "   Test 1: Sin filtros\n";
    $test1 = DB::connection($connection)->select("SELECT * FROM sp_reporte_catalogo_mercados(NULL, NULL) LIMIT 5;");
    echo "   ✓ Resultado: " . count($test1) . " registros\n";
    if (!empty($test1)) {
        $row = $test1[0];
        echo "   Ejemplo: Oficina={$row->oficina}, Mercado={$row->num_mercado_nvo}, Estado={$row->estado}\n";
    }

    // Test 2: Con filtro de oficina
    echo "\n   Test 2: Con filtro oficina=1\n";
    $test2 = DB::connection($connection)->select("SELECT * FROM sp_reporte_catalogo_mercados(1::SMALLINT, NULL) LIMIT 3;");
    echo "   ✓ Resultado: " . count($test2) . " registros\n";

    // Test 3: Con filtro de estado
    echo "\n   Test 3: Con filtro estado='A' (Activos)\n";
    $test3 = DB::connection($connection)->select("SELECT * FROM sp_reporte_catalogo_mercados(NULL, 'A') LIMIT 3;");
    echo "   ✓ Resultado: " . count($test3) . " registros\n";

    // Test 4: Con ambos filtros
    echo "\n   Test 4: Con filtro oficina=1 y estado='A'\n";
    $test4 = DB::connection($connection)->select("SELECT * FROM sp_reporte_catalogo_mercados(1::SMALLINT, 'A');");
    echo "   ✓ Resultado: " . count($test4) . " registros\n";

    echo "\n==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\nEl SP ahora acepta 2 parámetros opcionales:\n";
    echo "  - p_oficina (SMALLINT): Filtro por recaudadora\n";
    echo "  - p_estado (VARCHAR): Filtro por estado ('A'=Activo, 'I'=Inactivo)\n";
    echo "\nNOTA: Recarga el navegador para ver los cambios\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
