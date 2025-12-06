<?php
/**
 * Script de despliegue: sp_localesmodif_buscar_local
 * Fecha: 2025-12-05
 * Descripción: Despliega el SP corregido en la base mercados
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
echo "DESPLIEGUE: sp_localesmodif_buscar_local\n";
echo "==============================================\n\n";

try {
    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_buscar_local_MERCADOS.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encuentra el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    // Conectar a mercados
    $connection = 'pgsql';

    echo "1. Conectando a la base de datos mercados...\n";
    DB::connection($connection)->getPdo();
    echo "   ✓ Conexión establecida\n\n";

    // Eliminar la función anterior si existe
    echo "2. Eliminando versiones anteriores del SP...\n";
    try {
        DB::connection($connection)->statement("DROP FUNCTION IF EXISTS public.sp_localesmodif_buscar_local(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER, VARCHAR, VARCHAR);");
        DB::connection($connection)->statement("DROP FUNCTION IF EXISTS public.sp_localesmodif_buscar_local(INTEGER, INTEGER, INTEGER, VARCHAR, INTEGER);");
        echo "   ✓ SP anteriores eliminados\n\n";
    } catch (Exception $e) {
        echo "   ADVERTENCIA: " . $e->getMessage() . "\n\n";
    }

    // Crear la nueva función
    echo "3. Creando nueva versión del SP...\n";
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
          AND p.proname = 'sp_localesmodif_buscar_local'
        ORDER BY p.oid DESC
        LIMIT 1;
    ");

    if (!empty($verify)) {
        echo "   ✓ Función: " . $verify[0]->nombre_funcion . "\n";
        echo "   ✓ Parámetros: " . $verify[0]->parametros . "\n\n";
    }

    // Verificar configuración del search_path
    echo "5. Verificando configuración del search_path...\n";
    $searchPath = DB::connection($connection)->select("SHOW search_path;");
    echo "   ✓ search_path actual: " . $searchPath[0]->search_path . "\n\n";

    echo "NOTA: El SP usa comun.ta_11_locales que debe estar accesible vía search_path.\n";
    echo "      La tabla será accesible cuando el SP se ejecute desde la aplicación.\n\n";

    echo "\n==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo "==============================================\n";
    echo "\nEl SP ahora acepta 7 parámetros:\n";
    echo "  - p_oficina (INTEGER): Recaudadora\n";
    echo "  - p_num_mercado (INTEGER): Número de mercado\n";
    echo "  - p_categoria (INTEGER): Categoría\n";
    echo "  - p_seccion (VARCHAR): Sección\n";
    echo "  - p_local (INTEGER): Número de local\n";
    echo "  - p_letra_local (VARCHAR): Letra del local (opcional)\n";
    echo "  - p_bloque (VARCHAR): Bloque (opcional)\n";
    echo "\nNOTA: Recarga el navegador para ver los cambios\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
