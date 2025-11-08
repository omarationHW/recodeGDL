<?php
// Script para verificar SPs existentes para modlicfrm.vue

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

echo "\n=== VERIFICACIÓN DE SPs PARA modlicfrm.vue ===\n";
echo "Base de Datos: padron_licencias (192.168.6.146)\n";
echo "Esquema: comun\n\n";

$sps_requeridos = [
    // Licencias
    'sp_modlic_buscar_licencia',
    'sp_get_scian_catalogo',
    'sp_get_actividades_por_scian',
    'sp_get_saldo_licencia',
    'sp_modlic_actualizar_licencia',
    'sp_calc_sdos_lic',

    // Anuncios
    'sp_modlic_buscar_anuncio',
    'sp_get_tipos_anuncio',
    'sp_modlic_actualizar_anuncio',
    'sp_modlic_recalcular_adeudo_anuncio',

    // Mapa/Ubicación
    'sp_get_session_id',
    'sp_modlic_limpiar_sesion',
    'sp_get_ubicacion_sesion',
    'sp_modlic_actualizar_coordenadas',

    // Firma (ya debería existir)
    'sp_verifica_firma'
];

echo "SPs REQUERIDOS: " . count($sps_requeridos) . "\n\n";

$existentes = [];
$faltantes = [];

foreach ($sps_requeridos as $sp) {
    $existe = DB::selectOne("
        SELECT routine_name
        FROM information_schema.routines
        WHERE routine_schema = 'comun'
        AND routine_name = ?
    ", [$sp]);

    if ($existe) {
        $existentes[] = $sp;
        echo "✅ EXISTE: $sp\n";
    } else {
        $faltantes[] = $sp;
        echo "❌ FALTA:  $sp\n";
    }
}

echo "\n=== RESUMEN ===\n";
echo "Existentes: " . count($existentes) . "\n";
echo "Faltantes:  " . count($faltantes) . "\n\n";

if (count($faltantes) > 0) {
    echo "SPs FALTANTES:\n";
    foreach ($faltantes as $sp) {
        echo "  - $sp\n";
    }
}

echo "\n";
