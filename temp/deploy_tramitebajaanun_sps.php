<?php
/**
 * Deploy TramiteBajaAnun Stored Procedures
 * 3 SPs total para el componente TramiteBajaAnun.vue
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DEPLOYMENT: TramiteBajaAnun Stored Procedures ===\n";
echo "Conectando a base de datos...\n";

// Purge existing connection and configure
DB::purge('pgsql');
config(['database.connections.pgsql' => [
    'driver' => 'pgsql',
    'host' => '192.168.6.146',
    'port' => '5432',
    'database' => 'padron_licencias',
    'username' => 'refact',
    'password' => 'FF)-BQk2',
    'charset' => 'utf8',
    'prefix' => '',
    'schema' => 'comun',
]]);

DB::reconnect('pgsql');

// Leer el archivo SQL
$sqlFile = __DIR__ . '/DEPLOY_TRAMITEBAJAANUN_SPS.sql';

if (!file_exists($sqlFile)) {
    echo "ERROR: No se encontró el archivo SQL: $sqlFile\n";
    exit(1);
}

$sql = file_get_contents($sqlFile);

echo "Archivo SQL cargado: " . strlen($sql) . " bytes\n";
echo "Desplegando 3 Stored Procedures...\n\n";

try {
    // Desplegar todos los SPs usando unprepared (permite múltiples comandos)
    DB::unprepared($sql);

    echo "✓ SPs desplegados exitosamente\n\n";

    // Verificar que los 3 SPs fueron creados
    echo "Verificando creación de SPs en schema 'comun'...\n";

    $sps = DB::select("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name IN (
            'tramitebajaanun_sp_tramite_baja_anun_buscar',
            'tramitebajaanun_sp_tramite_baja_anun_tramitar',
            'tramitebajaanun_calc_sdosl'
        )
        ORDER BY routine_name
    ");

    echo "\nSPs encontrados (" . count($sps) . "/3):\n";
    foreach ($sps as $sp) {
        echo "  ✓ comun." . $sp->routine_name . "\n";
    }

    if (count($sps) === 3) {
        echo "\n✓✓✓ DEPLOYMENT EXITOSO - 3/3 SPs desplegados correctamente ✓✓✓\n";
        echo "\nTramiteBajaAnun.vue está listo para funcionar!\n";
    } else {
        echo "\n⚠ WARNING: Se esperaban 3 SPs pero se encontraron " . count($sps) . "\n";
    }

} catch (\Exception $e) {
    echo "\n✗ ERROR durante el deployment:\n";
    echo $e->getMessage() . "\n";
    exit(1);
}
