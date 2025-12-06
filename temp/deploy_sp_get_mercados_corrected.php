<?php
/**
 * Desplegar sp_get_mercados con categoria incluida
 */

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "DESPLIEGUE: sp_get_mercados (con categoria)\n";
echo "==============================================\n\n";

try {
    $connection = 'pgsql';

    // Primero eliminar todas las versiones existentes
    echo "1. Eliminando versiones anteriores...\n";
    DB::connection($connection)->unprepared("
        DROP FUNCTION IF EXISTS sp_get_mercados();
        DROP FUNCTION IF EXISTS sp_get_mercados(integer);
    ");
    echo "   ✓ Versiones anteriores eliminadas\n\n";

    // Crear la nueva versión con categoria
    echo "2. Creando nueva versión con categoria...\n";
    DB::connection($connection)->unprepared("
        CREATE OR REPLACE FUNCTION sp_get_mercados(p_oficina integer)
        RETURNS TABLE(
            oficina smallint,
            num_mercado_nvo smallint,
            categoria smallint,
            descripcion varchar
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                m.oficina,
                m.num_mercado_nvo,
                m.categoria,
                m.descripcion
            FROM ta_11_mercados m
            WHERE m.oficina = p_oficina
            ORDER BY m.num_mercado_nvo;
        END;
        \$\$ LANGUAGE plpgsql;

        COMMENT ON FUNCTION sp_get_mercados(integer) IS
        'Obtiene los mercados de una recaudadora/oficina con categoria incluida';
    ");
    echo "   ✓ Función creada\n\n";

    // Verificar
    echo "3. Verificando el despliegue...\n";
    $verify = DB::connection($connection)->select("
        SELECT
            p.proname AS nombre_funcion,
            pg_get_function_arguments(p.oid) AS parametros,
            pg_get_function_result(p.oid) AS resultado
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname = 'sp_get_mercados'
    ");

    if (!empty($verify)) {
        $func = $verify[0];
        echo "   ✓ Función: {$func->nombre_funcion}\n";
        echo "   ✓ Parámetros: {$func->parametros}\n";
        echo "   ✓ Resultado: {$func->resultado}\n\n";
    }

    // Probar
    echo "4. Probando la función...\n";
    $testOficina = DB::connection($connection)->select("
        SELECT DISTINCT oficina
        FROM ta_11_mercados
        WHERE oficina IS NOT NULL
        LIMIT 1
    ");

    if (!empty($testOficina)) {
        $oficina = $testOficina[0]->oficina;
        echo "   Oficina de prueba: $oficina\n";

        $result = DB::connection($connection)->select("
            SELECT * FROM sp_get_mercados($oficina)
        ");

        if (!empty($result)) {
            echo "   ✓ SP ejecutado exitosamente\n";
            echo "   ✓ Mercados encontrados: " . count($result) . "\n";
            $merc = $result[0];
            echo "   ✓ Primer mercado:\n";
            echo "     - oficina: {$merc->oficina}\n";
            echo "     - num_mercado_nvo: {$merc->num_mercado_nvo}\n";
            echo "     - categoria: {$merc->categoria}\n";
            echo "     - descripcion: {$merc->descripcion}\n";
        }
    }

    echo "\n==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO\n";
    echo "==============================================\n";
    echo "\nAhora el componente EnergiaModif.vue puede:\n";
    echo "  1. Cargar mercados al seleccionar recaudadora\n";
    echo "  2. Auto-llenar categoria al seleccionar mercado\n";
    echo "\nRecarga el navegador en /energia-modif\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "Traza: " . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
