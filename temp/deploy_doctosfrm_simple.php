<?php
/**
 * Deploy doctosfrm Stored Procedures - Simple Version
 * 4 SPs total para el componente doctosfrm.vue
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== DEPLOYMENT: doctosfrm Stored Procedures ===\n";
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
    'schema' => 'public',
]]);

DB::reconnect('pgsql');

// Leer el archivo SQL
$sqlFile = __DIR__ . '/DEPLOY_DOCTOSFRM_SPS.sql';

if (!file_exists($sqlFile)) {
    echo "ERROR: No se encontró el archivo SQL: $sqlFile\n";
    exit(1);
}

$sql = file_get_contents($sqlFile);

echo "Archivo SQL cargado: " . strlen($sql) . " bytes\n";
echo "Desplegando 4 Stored Procedures usando DB::unprepared()...\n\n";

try {
    // Desplegar todos los SPs usando unprepared (permite múltiples comandos)
    DB::unprepared($sql);

    echo "✓ SPs desplegados exitosamente\n\n";

    // Verificar que los 4 SPs fueron creados
    echo "Verificando creación de SPs en schema 'public'...\n";

    $sps = DB::select("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name IN ('sp_doctos_list', 'sp_doctos_create', 'sp_doctos_update', 'sp_doctos_delete')
        ORDER BY routine_name
    ");

    echo "\nSPs encontrados (" . count($sps) . "/4):\n";
    foreach ($sps as $sp) {
        echo "  ✓ " . $sp->routine_name . "\n";
    }

    if (count($sps) === 4) {
        echo "\n✓✓✓ DEPLOYMENT EXITOSO - 4/4 SPs desplegados correctamente ✓✓✓\n";
    } else {
        echo "\n⚠ WARNING: Se esperaban 4 SPs pero se encontraron " . count($sps) . "\n";
    }

} catch (\Exception $e) {
    echo "\n✗ ERROR durante el deployment:\n";
    echo $e->getMessage() . "\n";
    exit(1);
}
