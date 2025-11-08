<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql' => ['driver' => 'pgsql', 'host' => '192.168.6.146', 'port' => '5432', 'database' => 'padron_licencias', 'username' => 'refact', 'password' => 'FF)-BQk2', 'charset' => 'utf8', 'prefix' => '', 'schema' => 'comun']]);
DB::reconnect('pgsql');

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║       PRUEBA FINAL - REGISTRO CON SECUENCIA CORREGIDA         ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

$max_antes = DB::selectOne('SELECT MAX(id_tramite) as max_id FROM comun.tramites');
echo "MAX ID antes: " . $max_antes->max_id . "\n\n";

echo "Registrando solicitud...\n";
$result = DB::select("
    SELECT * FROM comun.sp_registro_solicitud(
        p_tipo_tramite := 1,
        p_id_giro := 100,
        p_actividad := 'PRUEBA FINAL CON SECUENCIA CORRECTA',
        p_propietario := 'PROPIETARIO PRUEBA FINAL',
        p_telefono := '33-0000-0000',
        p_email := 'prueba@final.com',
        p_calle := 'Av. Principal',
        p_colonia := 'Centro',
        p_cp := '44100',
        p_numext := '100',
        p_numint := NULL,
        p_letraext := NULL,
        p_letraint := NULL,
        p_zona := 1,
        p_subzona := 1,
        p_sup_const := 100.0,
        p_sup_autorizada := 100.0,
        p_num_cajones := 2,
        p_num_empleados := 5,
        p_inversion := 50000.0,
        p_rfc := 'XXXX000000XXX',
        p_curp := 'XXXX000000XXXXXX00',
        p_especificaciones := 'Prueba final',
        p_usuario := 'PRUEBAFIN'
    )
");

$id = $result[0]->id_tramite;
echo "\n✅ RESULTADO DEL SP:\n";
echo "   ID Trámite: " . $id . "\n";
echo "   Folio: " . ($result[0]->folio ?: 'NULL') . "\n";
echo "   Mensaje: " . $result[0]->mensaje . "\n\n";

// Verificar
$registro = DB::selectOne("
    SELECT id_tramite, propietario, actividad, estatus, feccap
    FROM comun.tramites
    WHERE id_tramite = ?
", [$id]);

echo "✅ VERIFICACIÓN EN BD:\n";
echo "   ID: " . $registro->id_tramite . "\n";
echo "   Propietario: " . trim($registro->propietario) . "\n";
echo "   Actividad: " . trim($registro->actividad) . "\n";
echo "   Estatus: " . trim($registro->estatus) . "\n";
echo "   Fecha: " . $registro->feccap . "\n\n";

$max_despues = DB::selectOne('SELECT MAX(id_tramite) as max_id FROM comun.tramites');
echo "MAX ID después: " . $max_despues->max_id . "\n\n";

if ($max_despues->max_id > $max_antes->max_id) {
    echo "✅ ¡ÉXITO! Se insertó un nuevo registro con ID > MAX anterior\n";
    
    // Limpiar
    echo "\nLimpiando registro de prueba...\n";
    DB::delete("DELETE FROM comun.tramites WHERE id_tramite = ?", [$id]);
    echo "✅ Registro eliminado\n";
} else {
    echo "⚠️  ADVERTENCIA: El registro sobrescribió uno existente\n";
}
