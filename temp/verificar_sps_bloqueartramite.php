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

echo "=== VERIFICACIÓN DE SPs BLOQUEARTRAMITE ===\n\n";

// Buscar en schema comun
echo "Buscando en schema 'comun':\n";
$sps_comun = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE '%bloqueartramite%'
    ORDER BY routine_name
");

echo "SPs encontrados en comun: " . count($sps_comun) . "\n";
foreach ($sps_comun as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}

// También buscar en licencias schema (aunque el componente dice 'licencias' podría ser un error)
echo "\nBuscando en schema 'licencias' (si existe):\n";
try {
    $sps_licencias = DB::select("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'licencias'
        AND routine_name LIKE '%bloqueartramite%'
        ORDER BY routine_name
    ");
    echo "SPs encontrados en licencias: " . count($sps_licencias) . "\n";
    foreach ($sps_licencias as $sp) {
        echo "  ✓ {$sp->routine_name}\n";
    }
} catch (\Exception $e) {
    echo "Schema 'licencias' no existe o no es accesible\n";
}

// Buscar en public también
echo "\nBuscando en schema 'public':\n";
$sps_public = DB::select("
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name LIKE '%bloqueartramite%'
    ORDER BY routine_name
");

echo "SPs encontrados en public: " . count($sps_public) . "\n";
foreach ($sps_public as $sp) {
    echo "  ✓ {$sp->routine_name}\n";
}

echo "\n=== SPs REQUERIDOS POR EL COMPONENTE ===\n";
$required = [
    'sp_bloqueartramite_get_tramite',
    'sp_bloqueartramite_get_bloqueos',
    'sp_bloqueartramite_get_giro',
    'sp_bloqueartramite_bloquear',
    'sp_bloqueartramite_desbloquear'
];

foreach ($required as $sp) {
    echo "  - $sp\n";
}
