<?php
/**
 * Verificar cómo Laravel está llamando al SP
 */

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "VERIFICACIÓN: Parámetros del SP\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    echo "1. Verificando SP desplegado...\n";
    $verify = DB::connection($connection)->select("
        SELECT
            p.proname AS nombre_funcion,
            p.pronargs AS num_params,
            pg_get_function_arguments(p.oid) AS parametros
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_localesmodif_modificar_local'
    ");

    if (!empty($verify)) {
        foreach ($verify as $func) {
            echo "   ✓ Función: {$func->nombre_funcion}\n";
            echo "   ✓ Número de parámetros: {$func->num_params}\n";
            echo "   ✓ Parámetros: {$func->parametros}\n\n";
        }
    }

    echo "2. Probando llamada con 18 parámetros via Laravel...\n";

    // Simular la llamada exacta que hace el frontend
    $params = [
        11257,                          // p_id_local
        'SANCHEZ BARRETO RICARDO',      // p_nombre
        'aaa',                          // p_domicilio
        '01',                           // p_sector
        1,                              // p_zona
        '1-B',                          // p_descripcion_local
        22.67,                          // p_superficie
        1667,                           // p_giro
        '2004-02-01',                   // p_fecha_alta
        null,                           // p_fecha_baja
        'A',                            // p_vigencia
        9,                              // p_clave_cuota
        1,                              // p_tipo_movimiento
        0,                              // p_bloqueo
        null,                           // p_cve_bloqueo
        null,                           // p_fecha_inicio_bloqueo
        null,                           // p_fecha_final_bloqueo
        ''                              // p_observacion
    ];

    echo "   Ejecutando con " . count($params) . " parámetros...\n";

    $placeholders = implode(',', array_fill(0, count($params), '?'));
    $sql = "SELECT * FROM public.sp_localesmodif_modificar_local($placeholders)";

    echo "   SQL: $sql\n\n";

    $result = DB::connection($connection)->select($sql, $params);

    if (!empty($result)) {
        echo "   ✓ Ejecutado exitosamente\n";
        echo "   ✓ Resultado: {$result[0]->result}\n\n";
    }

    echo "==============================================\n";
    echo "✓ PRUEBA COMPLETADA\n";
    echo "==============================================\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "\nDetalles del error:\n";
    echo "Código: " . $e->getCode() . "\n";

    // Si es un error de PostgreSQL, mostrar más detalles
    if (method_exists($e, 'getPrevious') && $e->getPrevious()) {
        echo "Error previo: " . $e->getPrevious()->getMessage() . "\n";
    }

    exit(1);
}
?>
