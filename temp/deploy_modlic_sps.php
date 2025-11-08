<?php
// Script para desplegar los 15 SPs de modlicfrm.vue

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

echo "\n=== DEPLOYMENT DE SPs - modlicfrm.vue ===\n";
echo "Base de Datos: padron_licencias (192.168.6.146)\n";
echo "Esquema: comun\n";
echo "SPs a Desplegar: 15\n\n";

// Leer archivo SQL
$sql = file_get_contents(__DIR__ . '/DEPLOY_MODLIC_SPS.sql');

if (!$sql) {
    echo "❌ ERROR: No se pudo leer el archivo DEPLOY_MODLIC_SPS.sql\n";
    exit(1);
}

echo "📄 Archivo SQL cargado: " . strlen($sql) . " bytes\n\n";

// Desplegar
try {
    echo "🚀 Desplegando stored procedures...\n\n";

    DB::unprepared($sql);

    echo "✅ DEPLOYMENT EXITOSO\n\n";

    // Verificar que se crearon los 15 SPs
    echo "=== VERIFICACIÓN DE SPs CREADOS ===\n";

    $sps_esperados = [
        'sp_modlic_buscar_licencia',
        'sp_modlic_buscar_anuncio',
        'sp_get_scian_catalogo',
        'sp_get_actividades_por_scian',
        'sp_get_tipos_anuncio',
        'sp_get_saldo_licencia',
        'sp_modlic_actualizar_licencia',
        'sp_modlic_actualizar_anuncio',
        'sp_calc_sdos_lic',
        'sp_modlic_recalcular_adeudo_anuncio',
        'sp_get_session_id',
        'sp_modlic_limpiar_sesion',
        'sp_get_ubicacion_sesion',
        'sp_modlic_actualizar_coordenadas',
        'sp_verifica_firma'
    ];

    $creados = 0;
    $faltantes = [];

    foreach ($sps_esperados as $sp) {
        $existe = DB::selectOne("
            SELECT routine_name
            FROM information_schema.routines
            WHERE routine_schema = 'comun'
            AND routine_name = ?
        ", [$sp]);

        if ($existe) {
            echo "✅ $sp\n";
            $creados++;
        } else {
            echo "❌ $sp (FALTA)\n";
            $faltantes[] = $sp;
        }
    }

    echo "\n=== RESUMEN ===\n";
    echo "Esperados: " . count($sps_esperados) . "\n";
    echo "Creados:   $creados\n";
    echo "Faltantes: " . count($faltantes) . "\n";

    if (count($faltantes) > 0) {
        echo "\n⚠️  ADVERTENCIA: Algunos SPs no se crearon:\n";
        foreach ($faltantes as $sp) {
            echo "  - $sp\n";
        }
        exit(1);
    } else {
        echo "\n🎉 TODOS LOS SPs SE CREARON EXITOSAMENTE\n";
    }

} catch (\Exception $e) {
    echo "\n❌ ERROR AL DESPLEGAR:\n";
    echo $e->getMessage() . "\n";
    exit(1);
}

echo "\n";
