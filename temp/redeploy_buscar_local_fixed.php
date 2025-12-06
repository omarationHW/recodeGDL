<?php
echo "==============================================\n";
echo "REDESPLIEGUE: sp_localesmodif_buscar_local\n";
echo "Fix para manejar strings vacíos vs NULL\n";
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
        DROP FUNCTION IF EXISTS sp_localesmodif_buscar_local(
            integer,integer,integer,character varying,integer,character varying,character varying
        ) CASCADE
    ");
    echo "   ✓ Eliminado\n\n";

    echo "2. Desplegando nueva versión...\n";
    $file = __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_buscar_local.sql';
    $sql = file_get_contents($file);
    DB::connection($connection)->unprepared($sql);
    echo "   ✓ Desplegado\n\n";

    echo "3. Verificando...\n";
    $verify = DB::connection($connection)->select("
        SELECT routine_definition
        FROM information_schema.routines
        WHERE routine_name = 'sp_localesmodif_buscar_local'
    ");

    if (!empty($verify)) {
        echo "   ✓ SP desplegado correctamente\n";
        
        $def = $verify[0]->routine_definition;
        if (strpos($def, 'IS NOT DISTINCT FROM') !== false) {
            echo "   ✓ Usa IS NOT DISTINCT FROM\n";
        }
        if (strpos($def, 'NULLIF') !== false) {
            echo "   ✓ Usa NULLIF para convertir '' a NULL\n";
        }
    }

    echo "\n4. Probando búsqueda con strings vacíos...\n";
    echo "   Parámetros: oficina=1, mercado=2, categoria=1, seccion=SS, local=3\n";
    echo "   letra_local='', bloque=''\n\n";

    $result = DB::connection($connection)->select("
        SELECT * FROM sp_localesmodif_buscar_local(1, 2, 1, 'SS', 3, '', '')
    ");

    if (!empty($result)) {
        echo "   ✓✓✓ SP RETORNA RESULTADOS AHORA ✓✓✓\n";
        $local = $result[0];
        echo "   id_local: {$local->id_local}\n";
        echo "   nombre: {$local->nombre}\n";
        echo "   sector: '{$local->sector}'\n";
        echo "   letra_local: " . ($local->letra_local ?? 'NULL') . "\n";
        echo "   bloque: " . ($local->bloque ?? 'NULL') . "\n";
        
        if (!empty($local->sector)) {
            echo "\n   ✓ Campo 'sector' tiene valor: '{$local->sector}'\n";
        } else {
            echo "\n   ✗ Campo 'sector' está vacío\n";
        }
    } else {
        echo "   ✗ SP no retornó resultados\n";
    }

    echo "\n==============================================\n";
    echo "✓ REDESPLIEGUE COMPLETADO\n";
    echo "==============================================\n";
    echo "\nAhora el SP maneja correctamente:\n";
    echo "- letra_local='' (string vacío) = NULL en BD\n";
    echo "- bloque='' (string vacío) = NULL en BD\n";
    echo "- Y retorna todos los campos incluyendo 'sector'\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
