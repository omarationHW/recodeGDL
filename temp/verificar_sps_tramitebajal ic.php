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

echo "=== VERIFICACIÓN DE SPs TRAMITEBAJALIC ===\n\n";

$required = [
    'TramiteBajaLic_sp_tramite_baja_lic_consulta',
    'TramiteBajaLic_spget_lic_adeudos',
    'TramiteBajaLic_sp_tramite_baja_lic_tramitar',
    'TramiteBajaLic_sp_recalcula_proporcional_baja',
    'TramiteBajaLic_sp_tramite_baja_lic_recalcula'
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
    AND routine_name LIKE '%tramitebajalic%'
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
    AND routine_name LIKE '%tramitebajalic%'
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
