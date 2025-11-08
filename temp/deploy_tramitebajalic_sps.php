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

echo "Desplegando 5 Stored Procedures para TramiteBajaLic...\n\n";

$sql = file_get_contents(__DIR__ . '/DEPLOY_TRAMITEBAJALIC_SPS.sql');
DB::unprepared($sql);

echo "Verificando SPs desplegados...\n\n";

$sps = DB::select("
    SELECT routine_name, routine_schema
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE 'tramitebajalic_%'
    ORDER BY routine_name
");

foreach ($sps as $sp) {
    echo "✓ {$sp->routine_schema}.{$sp->routine_name}\n";
}

echo "\n✓ Despliegue completado exitosamente\n";
