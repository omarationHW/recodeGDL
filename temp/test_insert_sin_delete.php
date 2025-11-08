<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "Registrando solicitud TEST FINAL...\n\n";

$result = DB::select("
    SELECT * FROM comun.sp_registro_solicitud(
        p_tipo_tramite := 1,
        p_id_giro := 999,
        p_actividad := 'PRUEBA DESDE SCRIPT PHP 2025',
        p_propietario := 'PROPIETARIO TEST SCRIPT',
        p_telefono := '33-9999-9999',
        p_email := 'script@test.com',
        p_calle := 'CALLE TEST',
        p_colonia := 'COLONIA TEST',
        p_cp := '99999',
        p_numext := '999',
        p_numint := NULL,
        p_letraext := NULL,
        p_letraint := NULL,
        p_zona := 99,
        p_subzona := 99,
        p_sup_const := 999.99,
        p_sup_autorizada := 999.99,
        p_num_cajones := 99,
        p_num_empleados := 99,
        p_inversion := 999999.99,
        p_rfc := 'TESTTEST123',
        p_curp := 'TESTTEST123456789',
        p_especificaciones := 'ESPECIFICACIONES DE PRUEBA',
        p_usuario := 'TESTSCRIPT'
    )
");

$id = $result[0]->id_tramite;
echo "ID retornado por SP: $id\n\n";

// Leer el registro directamente
$registro = DB::selectOne("
    SELECT
        id_tramite,
        folio,
        tipo_tramite,
        id_giro,
        propietario,
        actividad,
        telefono_prop,
        ubicacion,
        colonia_ubic,
        estatus,
        feccap,
        capturista
    FROM comun.tramites
    WHERE id_tramite = ?
", [$id]);

echo "DATOS EN LA BASE DE DATOS:\n";
echo "ID: " . $registro->id_tramite . "\n";
echo "Propietario: [" . trim($registro->propietario) . "]\n";
echo "Actividad: [" . trim($registro->actividad) . "]\n";
echo "Teléfono: [" . trim($registro->telefono_prop) . "]\n";
echo "Ubicación: [" . trim($registro->ubicacion) . "]\n";
echo "Colonia: [" . trim($registro->colonia_ubic) . "]\n";
echo "ID Giro: " . $registro->id_giro . "\n";
echo "Estatus: [" . trim($registro->estatus) . "]\n";
echo "Fecha: " . $registro->feccap . "\n";
echo "Capturista: [" . trim($registro->capturista) . "]\n";
