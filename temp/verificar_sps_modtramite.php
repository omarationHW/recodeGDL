<?php
/**
 * Verificar SPs existentes que podemos reutilizar para modtramitefrm
 */

require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';

$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

// Configurar conexión
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

echo "=== VERIFICACIÓN DE SPs EXISTENTES PARA MODTRAMITEFRM ===\n\n";

// Lista de SPs que necesitamos
$sps_necesarios = [
    'sp_get_tramite_by_id',
    'sp_get_giro_by_id',
    'sp_update_tramite',
    'sp_get_giros_list',
    'sp_get_actividades_by_giro',
    'sp_get_calles',
    'sp_get_colonias',
    'consulta_giros_estadisticas'
];

echo "SPs NECESARIOS:\n";
echo str_repeat("=", 80) . "\n";

foreach ($sps_necesarios as $sp) {
    echo "- $sp\n";
}

echo "\n\nVERIFICACIÓN EN ESQUEMA 'comun':\n";
echo str_repeat("=", 80) . "\n";

$existentes = DB::select("
    SELECT
        routine_name,
        routine_type,
        routine_schema
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name IN ('" . implode("','", $sps_necesarios) . "')
    ORDER BY routine_name
");

foreach ($existentes as $sp) {
    echo "✓ {$sp->routine_name} ({$sp->routine_type}) - EXISTE en esquema {$sp->routine_schema}\n";
}

// Ver qué SPs faltan
$existentes_nombres = array_map(function($sp) {
    return $sp->routine_name;
}, $existentes);

$faltantes = array_diff($sps_necesarios, $existentes_nombres);

echo "\n\nSPs FALTANTES:\n";
echo str_repeat("=", 80) . "\n";

if (count($faltantes) > 0) {
    foreach ($faltantes as $sp) {
        echo "✗ $sp - FALTA (hay que crearlo)\n";
    }
} else {
    echo "✓ Todos los SPs necesarios existen\n";
}

// Verificar SPs de giros que podrían ser útiles
echo "\n\nSPs RELACIONADOS CON GIROS:\n";
echo str_repeat("=", 80) . "\n";

$giros_sps = DB::select("
    SELECT
        routine_name,
        routine_type
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND routine_name LIKE '%giro%'
    ORDER BY routine_name
");

foreach ($giros_sps as $sp) {
    echo "- {$sp->routine_name} ({$sp->routine_type})\n";
}

// Verificar SPs de catálogos
echo "\n\nSPs DE CATÁLOGOS:\n";
echo str_repeat("=", 80) . "\n";

$catalogos_sps = DB::select("
    SELECT
        routine_name,
        routine_type
    FROM information_schema.routines
    WHERE routine_schema = 'comun'
    AND (routine_name LIKE '%calle%' OR routine_name LIKE '%colonia%')
    ORDER BY routine_name
");

foreach ($catalogos_sps as $sp) {
    echo "- {$sp->routine_name} ({$sp->routine_type})\n";
}

echo "\n\n=== VERIFICACIÓN COMPLETADA ===\n";
