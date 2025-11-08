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
    'schema' => 'public',
]]);
DB::reconnect('pgsql');

echo "=== VERIFICACIÓN DE SPs DOCTOS ===\n\n";

$sps = DB::select("
    SELECT
        routine_name,
        routine_schema,
        specific_name,
        pg_get_functiondef((routine_schema || '.' || routine_name)::regproc::oid) as definition_preview
    FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name LIKE 'sp_doctos%'
    ORDER BY routine_name, specific_name
");

echo "SPs encontrados: " . count($sps) . "\n\n";

foreach ($sps as $sp) {
    echo "------------------------------------------------------------\n";
    echo "Nombre: {$sp->routine_schema}.{$sp->routine_name}\n";
    echo "Specific Name: {$sp->specific_name}\n";
    echo "\n";
}

// Ver los parámetros de cada función
echo "\n=== PARÁMETROS DE CADA FUNCIÓN ===\n\n";

$params = DB::select("
    SELECT
        r.routine_name,
        p.parameter_name,
        p.data_type,
        p.ordinal_position
    FROM information_schema.routines r
    LEFT JOIN information_schema.parameters p
        ON r.specific_name = p.specific_name
    WHERE r.routine_schema = 'public'
    AND r.routine_name LIKE 'sp_doctos%'
    AND (p.parameter_mode = 'IN' OR p.parameter_mode IS NULL)
    ORDER BY r.routine_name, p.ordinal_position
");

$current_routine = null;
foreach ($params as $param) {
    if ($current_routine !== $param->routine_name) {
        $current_routine = $param->routine_name;
        echo "\n{$param->routine_name}:\n";
    }
    if ($param->parameter_name) {
        echo "  - {$param->parameter_name} ({$param->data_type})\n";
    } else {
        echo "  (sin parámetros)\n";
    }
}
