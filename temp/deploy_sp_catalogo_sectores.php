<?php
echo "==============================================\n";
echo "DESPLIEGUE: sp_catalogo_sectores\n";
echo "==============================================\n\n";

chdir(__DIR__ . '/../RefactorX/BackEnd');
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use Illuminate\Support\Facades\DB;

try {
    $connection = 'pgsql';

    echo "1. Eliminando versión anterior (si existe)...\n";
    DB::connection($connection)->statement("DROP FUNCTION IF EXISTS sp_catalogo_sectores() CASCADE");
    echo "   ✓ Eliminado\n\n";

    echo "2. Desplegando nuevo SP...\n";
    $file = __DIR__ . '/../RefactorX/Base/mercados/database/database/LocalesModif_sp_catalogo_sectores.sql';
    $sql = file_get_contents($file);
    DB::connection($connection)->unprepared($sql);
    echo "   ✓ Desplegado\n\n";

    echo "3. Probando el SP...\n";
    $result = DB::connection($connection)->select("SELECT * FROM sp_catalogo_sectores() ORDER BY clave");

    if (!empty($result)) {
        echo "   ✓ SP retorna " . count($result) . " sectores:\n\n";
        foreach ($result as $sector) {
            echo "     {$sector->clave} → {$sector->descripcion}\n";
        }
    } else {
        echo "   ✗ SP no retornó resultados\n";
    }

    echo "\n==============================================\n";
    echo "✓ DESPLIEGUE COMPLETADO\n";
    echo "==============================================\n";
    echo "\nAhora actualiza LocalesModif.vue para usar este SP.\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
