<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

// Ver el último ID antes de insertar
echo "📊 Último ID tramite ANTES de insertar:\n";
$ultimo = DB::selectOne("SELECT MAX(id_tramite) as max_id FROM comun.tramites");
echo "MAX ID: " . $ultimo->max_id . "\n\n";

echo "🔄 Insertando registro...\n";
$result = DB::select("
    SELECT * FROM comun.sp_registro_solicitud(
        p_tipo_tramite := 99,
        p_id_giro := 88888,
        p_actividad := 'TEST ACTIVIDAD UNICA 202511',
        p_propietario := 'TEST PROPIETARIO UNICO 202511',
        p_telefono := '99-9999-9999',
        p_email := 'test202511@test.com',
        p_calle := 'TEST CALLE 202511',
        p_colonia := 'TEST COLONIA 202511',
        p_cp := '00000',
        p_numext := '0',
        p_numint := NULL,
        p_letraext := NULL,
        p_letraint := NULL,
        p_zona := 0,
        p_subzona := 0,
        p_sup_const := 0.0,
        p_sup_autorizada := 0.0,
        p_num_cajones := 0,
        p_num_empleados := 0,
        p_inversion := 0.0,
        p_rfc := 'TEST202511',
        p_curp := 'TEST202511',
        p_especificaciones := 'TEST ESPECIFICACIONES 202511',
        p_usuario := 'TEST202511'
    )
");

$id_retornado = $result[0]->id_tramite;
echo "ID retornado por SP: $id_retornado\n\n";

echo "📊 Último ID tramite DESPUÉS de insertar:\n";
$ultimo2 = DB::selectOne("SELECT MAX(id_tramite) as max_id FROM comun.tramites");
echo "MAX ID: " . $ultimo2->max_id . "\n\n";

// Buscar registros con nuestras keywords
echo "🔍 Buscando registros con 'TEST 202511'...\n";
$test_records = DB::select("
    SELECT id_tramite, propietario, actividad, capturista
    FROM comun.tramites
    WHERE
        propietario LIKE '%TEST%202511%'
        OR actividad LIKE '%TEST%202511%'
        OR capturista LIKE '%TEST202511%'
    ORDER BY id_tramite DESC
    LIMIT 5
");

if (count($test_records) > 0) {
    echo "✅ REGISTROS ENCONTRADOS:\n";
    foreach ($test_records as $r) {
        echo "  ID: " . $r->id_tramite . " - " . trim($r->propietario) . " - " . trim($r->actividad) . "\n";
    }
} else {
    echo "❌ NO SE ENCONTRÓ NINGÚN REGISTRO CON NUESTROS DATOS\n";
}
