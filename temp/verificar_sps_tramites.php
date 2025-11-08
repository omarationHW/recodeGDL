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

echo "=== VERIFICACIÓN DE SPs DE TRÁMITES ===\n\n";

// Verificar SPs de TramiteBajaLic
echo "📋 TramiteBajaLic - 5 SPs esperados:\n";
$sps_bajalic = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE 'tramitebajalic_%'
    ORDER BY routine_name
");

foreach ($sps_bajalic as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}
echo "  Total: " . count($sps_bajalic) . " SPs\n\n";

// Verificar SPs de TramiteBajaAnun
echo "📋 TramiteBajaAnun - 3 SPs esperados:\n";
$sps_bajaanun = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE 'tramitebajaanun_%'
    ORDER BY routine_name
");

foreach ($sps_bajaanun as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}
echo "  Total: " . count($sps_bajaanun) . " SPs\n\n";

// Verificar SPs de cancelaTramite
echo "📋 cancelaTramite - 3 SPs esperados:\n";
$sps_cancela = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE 'sp_%tramite%'
    AND (routine_name LIKE '%cancel%' OR routine_name LIKE '%get_tramite%')
    ORDER BY routine_name
");

foreach ($sps_cancela as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}
echo "  Total: " . count($sps_cancela) . " SPs\n\n";

// Resumen
echo "=== RESUMEN ===\n";
echo "✅ TramiteBajaLic: " . count($sps_bajalic) . " SPs\n";
echo "✅ TramiteBajaAnun: " . count($sps_bajaanun) . " SPs\n";
echo "✅ cancelaTramite: " . count($sps_cancela) . " SPs\n";
echo "\n✓ Verificación completada\n";
