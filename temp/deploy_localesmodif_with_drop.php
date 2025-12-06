<?php
echo "==============================================\n";
echo "DESPLIEGUE: SPs LocalesModif con DROP\n";
echo "==============================================\n\n";

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

try {
    $connection = 'pgsql';

    $sps = [
        [
            'name' => 'sp_localesmodif_buscar_local',
            'file' => __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_buscar_local.sql',
            'signature' => 'sp_localesmodif_buscar_local(integer,integer,integer,character varying,integer,character varying,character varying)'
        ],
        [
            'name' => 'sp_localesmodif_modificar_local',
            'file' => __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_modificar_local.sql',
            'signature' => 'sp_localesmodif_modificar_local(integer,character varying,character varying,character varying,integer,character varying,numeric,integer,date,date,character varying,integer,integer,integer,integer,date,date,character varying)'
        ]
    ];

    foreach ($sps as $sp) {
        echo "Procesando: {$sp['name']}\n";

        // 1. DROP la función existente
        echo "   1. Eliminando versión anterior...\n";
        try {
            DB::connection($connection)->statement("DROP FUNCTION IF EXISTS {$sp['signature']} CASCADE");
            echo "      ✓ Eliminado\n";
        } catch (Exception $e) {
            echo "      ⚠ No existía o no se pudo eliminar: " . $e->getMessage() . "\n";
        }

        // 2. Crear nueva versión
        echo "   2. Creando nueva versión...\n";
        if (!file_exists($sp['file'])) {
            echo "      ✗ Archivo no encontrado: {$sp['file']}\n";
            continue;
        }

        $sql = file_get_contents($sp['file']);
        if (empty($sql)) {
            echo "      ✗ Archivo vacío\n";
            continue;
        }

        DB::connection($connection)->unprepared($sql);
        echo "      ✓ Creado exitosamente\n";

        // 3. Verificar
        echo "   3. Verificando...\n";
        $verify = DB::connection($connection)->select("
            SELECT routine_name, routine_definition
            FROM information_schema.routines
            WHERE routine_name = ?
        ", [$sp['name']]);

        if (!empty($verify)) {
            echo "      ✓ SP desplegado correctamente\n";

            $def = $verify[0]->routine_definition;
            if (strpos($def, 'publico.ta_11_locales') !== false) {
                echo "      ✓ Usa tabla correcta: publico.ta_11_locales\n";
            } elseif (strpos($def, 'public.ta_11_localpaso') !== false) {
                echo "      ✗ ADVERTENCIA: Todavía usa public.ta_11_localpaso\n";
            }
        } else {
            echo "      ✗ No se pudo verificar\n";
        }

        echo "\n";
    }

    echo "==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO\n";
    echo "==============================================\n";

    // Test final
    echo "\nPrueba rápida del SP de búsqueda...\n";
    $test = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_buscar_local(1, 10, 1, '01', 1, null, null)
    ");

    if (!empty($test)) {
        echo "✓ SP de búsqueda funciona correctamente\n";
        echo "  Encontrado: {$test[0]->nombre}\n";
        echo "  Domicilio actual: '{$test[0]->domicilio}'\n";
    } else {
        echo "⚠ No se encontraron resultados (puede ser normal si no existe ese local)\n";
    }

    echo "\n==============================================\n";
    echo "INSTRUCCIONES\n";
    echo "==============================================\n";
    echo "1. Recarga /locales-modif en el navegador\n";
    echo "2. Busca un local existente\n";
    echo "3. Modifica el domicilio\n";
    echo "4. Guarda los cambios\n";
    echo "5. Busca de nuevo para verificar que se guardó\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
?>
