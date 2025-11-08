<?php
/**
 * Script para probar sp_update_tramite y diagnosticar el error
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

echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
echo "║               TEST SP_UPDATE_TRAMITE - DIAGNÓSTICO DE ERROR                 ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

// Obtener un trámite de prueba que esté en estado T o R
echo "📝 Buscando un trámite en estado T (En Trámite) o R (Rechazado)...\n";
$tramite = DB::selectOne("
    SELECT
        id_tramite,
        folio,
        estatus,
        primer_ap,
        segundo_ap,
        propietario,
        rfc,
        curp,
        id_giro,
        actividad
    FROM comun.tramites
    WHERE estatus IN ('T', 'R')
    LIMIT 1
");

if (!$tramite) {
    echo "❌ No se encontró ningún trámite en estado T o R para probar\n";
    exit(1);
}

echo "✅ Trámite encontrado:\n";
echo "   ID: {$tramite->id_tramite}\n";
echo "   Folio: {$tramite->folio}\n";
echo "   Estado: {$tramite->estatus}\n";
echo "   Propietario: {$tramite->primer_ap} {$tramite->segundo_ap} {$tramite->propietario}\n";
echo "   RFC: {$tramite->rfc}\n\n";

// Intentar actualizar con el SP
echo "🔄 Intentando actualizar con sp_update_tramite...\n\n";

try {
    $result = DB::select("
        SELECT * FROM comun.sp_update_tramite(
            p_id_tramite := ?,
            p_primer_ap := ?,
            p_segundo_ap := ?,
            p_propietario := ?,
            p_rfc := ?,
            p_curp := ?,
            p_telefono_prop := ?,
            p_email := ?,
            p_domicilio := ?,
            p_numext_prop := ?,
            p_numint_prop := ?,
            p_colonia_prop := ?,
            p_cvecalle := ?,
            p_ubicacion := ?,
            p_numext_ubic := ?,
            p_numint_ubic := ?,
            p_letraext_ubic := ?,
            p_letraint_ubic := ?,
            p_colonia_ubic := ?,
            p_espubic := ?,
            p_zona := ?,
            p_subzona := ?,
            p_cp := ?,
            p_id_giro := ?,
            p_actividad := ?,
            p_sup_construida := ?,
            p_sup_autorizada := ?,
            p_num_cajones := ?,
            p_num_empleados := ?,
            p_aforo := ?,
            p_inversion := ?,
            p_rhorario := ?,
            p_observaciones := ?,
            p_usuario := ?
        )
    ", [
        $tramite->id_tramite,
        $tramite->primer_ap ?: '',
        $tramite->segundo_ap ?: '',
        $tramite->propietario ?: '',
        $tramite->rfc ?: '',
        $tramite->curp ?: '',
        '',  // telefono
        '',  // email
        '',  // domicilio
        null, // numext_prop
        '',  // numint_prop
        '',  // colonia_prop
        null, // cvecalle
        '',  // ubicacion
        null, // numext_ubic
        '',  // numint_ubic
        '',  // letraext_ubic
        '',  // letraint_ubic
        '',  // colonia_ubic
        '',  // espubic
        null, // zona
        null, // subzona
        null, // cp
        $tramite->id_giro,
        $tramite->actividad ?: '',
        null, // sup_construida
        null, // sup_autorizada
        null, // num_cajones
        null, // num_empleados
        null, // aforo
        null, // inversion
        '',  // rhorario
        'TEST - Actualización de prueba desde PHP', // observaciones
        'TEST_USER' // usuario
    ]);

    echo "✅ SP ejecutado exitosamente\n\n";
    echo "📊 Respuesta del SP:\n";
    echo json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n\n";

    if (isset($result[0])) {
        $json = json_decode($result[0]->sp_update_tramite);
        echo "📋 JSON parseado:\n";
        echo "   success: " . ($json->success ? 'true' : 'false') . "\n";
        echo "   message: " . $json->message . "\n";
        if (isset($json->id_tramite)) {
            echo "   id_tramite: " . $json->id_tramite . "\n";
        }
    }

} catch (Exception $e) {
    echo "❌ ERROR al ejecutar SP:\n";
    echo "   Mensaje: " . $e->getMessage() . "\n\n";
    echo "   Stack trace:\n";
    echo $e->getTraceAsString() . "\n";
}

echo "\n✅ Test completado\n";
