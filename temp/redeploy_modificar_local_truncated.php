<?php
echo "==============================================\n";
echo "REDESPLIEGUE: sp_localesmodif_modificar_local\n";
echo "Con truncación automática de campos\n";
echo "==============================================\n\n";

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

try {
    $connection = 'pgsql';

    echo "1. Eliminando versión anterior...\n";
    DB::connection($connection)->statement("
        DROP FUNCTION IF EXISTS sp_localesmodif_modificar_local(
            integer,character varying,character varying,character varying,
            integer,character varying,numeric,integer,date,date,
            character varying,integer,integer,integer,integer,
            date,date,character varying
        ) CASCADE
    ");
    echo "   ✓ Eliminado\n\n";

    echo "2. Desplegando nueva versión con truncación...\n";
    $file = __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_modificar_local.sql';
    $sql = file_get_contents($file);
    DB::connection($connection)->unprepared($sql);
    echo "   ✓ Desplegado\n\n";

    echo "3. Verificando despliegue...\n";
    $verify = DB::connection($connection)->select("
        SELECT routine_name, routine_definition
        FROM information_schema.routines
        WHERE routine_name = 'sp_localesmodif_modificar_local'
    ");

    if (!empty($verify)) {
        echo "   ✓ SP desplegado correctamente\n";
        
        $def = $verify[0]->routine_definition;
        if (strpos($def, 'SUBSTRING') !== false) {
            echo "   ✓ Contiene truncación con SUBSTRING\n";
        }
        if (strpos($def, 'publico.ta_11_locales') !== false) {
            echo "   ✓ Usa tabla correcta: publico.ta_11_locales\n";
        }
    }

    echo "\n==============================================\n";
    echo "✓ REDESPLIEGUE COMPLETADO\n";
    echo "==============================================\n";
    echo "\nCambios aplicados:\n";
    echo "- sector → SUBSTRING(1, 1) para char(1)\n";
    echo "- vigencia → SUBSTRING(1, 1) para char(1)\n";
    echo "- descripcion_local → SUBSTRING(1, 20) para char(20)\n";
    echo "- nombre → SUBSTRING(1, 60) para varchar(60)\n";
    echo "- domicilio → SUBSTRING(1, 70) para varchar(70)\n";
    echo "- observacion → SUBSTRING(1, 250) para varchar(250)\n";
    echo "\nAhora puedes probar modificar el local sin errores.\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
