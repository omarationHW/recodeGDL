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

echo "=== VERIFICACIÓN DE SPs CONSULTATRAMITE ===\n\n";

$required = [
    'consulta_tramites_list',
    'consulta_tramites_estadisticas'
];

echo "SPs requeridos: " . count($required) . "\n";
foreach ($required as $sp) {
    echo "  - $sp\n";
}

echo "\nBuscando en schema 'comun':\n";
$sps_comun = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND (routine_name = 'consulta_tramites_list' OR routine_name = 'consulta_tramites_estadisticas')
    ORDER BY routine_name
");

echo "SPs encontrados en comun: " . count($sps_comun) . "/" . count($required) . "\n";
foreach ($sps_comun as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}

echo "\nBuscando en schema 'public':\n";
$sps_public = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND (routine_name = 'consulta_tramites_list' OR routine_name = 'consulta_tramites_estadisticas')
    ORDER BY routine_name
");

echo "SPs encontrados en public: " . count($sps_public) . "/" . count($required) . "\n";
foreach ($sps_public as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}

$total_found = count($sps_comun) + count($sps_public);
if ($total_found < count($required)) {
    echo "\n⚠ FALTAN " . (count($required) - $total_found) . " SPs POR DESPLEGAR\n";
} else {
    echo "\n✓✓✓ TODOS LOS SPs ESTÁN DESPLEGADOS\n";
}
