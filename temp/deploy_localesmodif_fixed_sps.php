<?php
echo "==============================================\n";
echo "DESPLIEGUE: SPs LocalesModif Corregidos\n";
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
        'sp_localesmodif_buscar_local' => __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_buscar_local.sql',
        'sp_localesmodif_modificar_local' => __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_modificar_local.sql'
    ];

    foreach ($sps as $name => $file) {
        echo "Desplegando: $name\n";

        if (!file_exists($file)) {
            echo "   ✗ Archivo no encontrado: $file\n";
            continue;
        }

        $sql = file_get_contents($file);

        if (empty($sql)) {
            echo "   ✗ Archivo vacío\n";
            continue;
        }

        DB::connection($connection)->unprepared($sql);
        echo "   ✓ Desplegado exitosamente\n";

        // Verificar despliegue
        $verify = DB::connection($connection)->select("
            SELECT routine_name, routine_definition
            FROM information_schema.routines
            WHERE routine_name = ?
        ", [$name]);

        if (!empty($verify)) {
            // Verificar qué tabla usa
            $def = $verify[0]->routine_definition;
            if (strpos($def, 'publico.ta_11_locales') !== false) {
                echo "   ✓ Usa tabla correcta: publico.ta_11_locales\n";
            } elseif (strpos($def, 'public.ta_11_localpaso') !== false) {
                echo "   ✗ ADVERTENCIA: Todavía usa public.ta_11_localpaso\n";
            }
        }

        echo "\n";
    }

    echo "==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO\n";
    echo "==============================================\n";
    echo "\nPrueba en el navegador:\n";
    echo "1. Recarga /locales-modif\n";
    echo "2. Busca el local con id_local=11257\n";
    echo "3. Modifica el domicilio a '222222'\n";
    echo "4. Guarda los cambios\n";
    echo "5. Busca de nuevo para verificar que se guardó\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
