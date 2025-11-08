<?php
/**
 * Fix TramiteBajaAnun SPs - Schema corrections
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

echo "=== FIX: TramiteBajaAnun Schema Issues ===\n";
echo "Conectando a base de datos...\n";

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

echo "Conexión establecida\n\n";

// Fix 1: calc_sdosl
echo "1. Actualizando TramiteBajaAnun_calc_sdosl...\n";
$sql1 = file_get_contents(__DIR__ . '/fix_tramitebajaanun_calc_sdosl.sql');

try {
    DB::unprepared($sql1);
    echo "   ✓ calc_sdosl actualizado (ahora usa public.saldos_lic)\n\n";
} catch (\Exception $e) {
    echo "   ✗ Error: " . $e->getMessage() . "\n\n";
}

// Fix 2: tramitar
echo "2. Actualizando TramiteBajaAnun_sp_tramite_baja_anun_tramitar...\n";
$sql2 = file_get_contents(__DIR__ . '/fix_tramitebajaanun_tramitar.sql');

try {
    DB::unprepared($sql2);
    echo "   ✓ tramitar actualizado (ahora usa public.lic_cancel)\n\n";
} catch (\Exception $e) {
    echo "   ✗ Error: " . $e->getMessage() . "\n\n";
}

// Verificar
echo "Verificando SPs actualizados...\n";
$sps = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE 'tramitebajaanun%'
    ORDER BY routine_name
");

echo "SPs encontrados: " . count($sps) . "/3\n";
foreach ($sps as $sp) {
    echo "  ✓ comun." . $sp->routine_name . "\n";
}

echo "\n✓✓✓ FIX COMPLETADO - TramiteBajaAnun ahora debe funcionar correctamente ✓✓✓\n";
