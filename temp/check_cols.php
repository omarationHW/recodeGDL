<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;
DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');
$cols = DB::select("SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_schema = 'comun' AND table_name = 'tramites' AND column_name IN ('tipo_tramite', 'propietario', 'telefono_prop', 'ubicacion', 'colonia_ubic', 'capturista', 'estatus', 'actividad') ORDER BY column_name");
foreach ($cols as $c) {
    echo $c->column_name . ': ' . $c->data_type;
    if ($c->character_maximum_length) echo '(' . $c->character_maximum_length . ')';
    echo PHP_EOL;
}
