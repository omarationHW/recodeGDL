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

echo "╔════════════════════════════════════════════════════════════════╗\n";
echo "║       PRUEBA COMPLETA DE REGISTRO DE SOLICITUD                ║\n";
echo "╚════════════════════════════════════════════════════════════════╝\n\n";

echo "1️⃣  Registrando nueva solicitud...\n";

try {
    $result = DB::select("
        SELECT * FROM comun.sp_registro_solicitud(
            p_tipo_tramite := 1,
            p_id_giro := 100,
            p_actividad := 'Venta de abarrotes y productos de primera necesidad',
            p_propietario := 'Juan Pérez García',
            p_telefono := '33-1234-5678',
            p_email := 'juan.perez@ejemplo.com',
            p_calle := 'Av. Juárez',
            p_colonia := 'Centro',
            p_cp := '44100',
            p_numext := '123',
            p_numint := 'A',
            p_letraext := NULL,
            p_letraint := NULL,
            p_zona := 1,
            p_subzona := 1,
            p_sup_const := 50.5,
            p_sup_autorizada := 50.5,
            p_num_cajones := 2,
            p_num_empleados := 3,
            p_inversion := 100000.00,
            p_rfc := 'PEGJ800101ABC',
            p_curp := 'PEGJ800101HJCRNN00',
            p_especificaciones := 'Tienda de abarrotes familiar',
            p_usuario := 'TEST_USER'
        )
    ");

    if (count($result) > 0) {
        $tramite = $result[0];
        echo "✅ Solicitud registrada exitosamente\n";
        echo "   ID Trámite: " . $tramite->id_tramite . "\n";
        echo "   Folio: " . ($tramite->folio ?: 'NULL') . "\n";
        echo "   Mensaje: " . $tramite->mensaje . "\n\n";

        // Verificar que se insertó correctamente
        echo "2️⃣  Verificando que el registro existe...\n";

        $tramiteVerificado = DB::selectOne("
            SELECT
                id_tramite,
                folio,
                tipo_tramite,
                propietario,
                actividad,
                estatus,
                feccap
            FROM comun.tramites
            WHERE id_tramite = ?
        ", [$tramite->id_tramite]);

        if ($tramiteVerificado) {
            echo "✅ Trámite encontrado en la base de datos\n";
            echo "   ID: " . $tramiteVerificado->id_tramite . "\n";
            echo "   Folio: " . ($tramiteVerificado->folio ?: 'NULL') . "\n";
            echo "   Tipo: " . trim($tramiteVerificado->tipo_tramite) . "\n";
            echo "   Propietario: " . trim($tramiteVerificado->propietario) . "\n";
            echo "   Actividad: " . trim($tramiteVerificado->actividad) . "\n";
            echo "   Estatus: " . trim($tramiteVerificado->estatus) . "\n";
            echo "   Fecha Captura: " . $tramiteVerificado->feccap . "\n\n";

            // Limpiar - eliminar el registro de prueba
            echo "3️⃣  Eliminando registro de prueba...\n";
            DB::delete("DELETE FROM comun.tramites WHERE id_tramite = ?", [$tramite->id_tramite]);
            echo "✅ Registro eliminado\n\n";
        } else {
            echo "❌ ERROR: Trámite no encontrado en la base de datos\n\n";
        }

    } else {
        echo "❌ ERROR: No se obtuvo respuesta del SP\n\n";
    }

    echo "✅ Prueba completada exitosamente\n";

} catch (Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
}
