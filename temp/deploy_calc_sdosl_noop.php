<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

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

echo "Actualizando calc_sdosl a NO-OP...\n";
$sql = file_get_contents(__DIR__ . '/fix_calc_sdosl_noop.sql');
DB::unprepared($sql);
echo "✓ calc_sdosl actualizado - ahora es NO-OP\n";
echo "✓ TramiteBajaAnun debería funcionar correctamente\n";
