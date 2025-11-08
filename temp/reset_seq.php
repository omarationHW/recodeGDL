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

$max = DB::selectOne('SELECT MAX(id_tramite) as max_id FROM comun.tramites');
echo "MAX ID en tabla: " . $max->max_id . "\n";

// Resetear secuencia al MAX actual
DB::statement("SELECT setval('comun.tramites_id_tramite_seq', " . $max->max_id . ")");

// Verificar
$last = DB::selectOne("SELECT last_value FROM comun.tramites_id_tramite_seq");
echo "Secuencia reseteada a: " . $last->last_value . "\n";
echo "Próximo ID será: " . ($last->last_value + 1) . "\n";
