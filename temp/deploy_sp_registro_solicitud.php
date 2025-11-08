<?php
/**
 * Script para desplegar SP de REGISTRO/CREACIÓN de solicitudes
 * Componente: Registro de Solicitud
 * Acción: INSERT en comun.tramites
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
echo "║            DESPLIEGUE SP_REGISTRO_SOLICITUD - CREAR TRÁMITES                ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

try {
    // Primero verificar la estructura de la tabla tramites
    echo "📋 Verificando estructura de comun.tramites...\n";

    $columns = DB::select("
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'tramites'
        ORDER BY ordinal_position
    ");

    echo "   Columnas encontradas: " . count($columns) . "\n";
    $hasSequence = false;

    foreach ($columns as $col) {
        if ($col->column_name === 'id_tramite') {
            echo "   ✅ id_tramite: " . $col->data_type;
            if (strpos($col->column_default, 'nextval') !== false) {
                echo " (AUTO INCREMENT)";
                $hasSequence = true;
            }
            echo "\n";
        }
        if ($col->column_name === 'folio') {
            echo "   ✅ folio: " . $col->data_type;
            if (strpos($col->column_default, 'nextval') !== false) {
                echo " (AUTO INCREMENT)";
            }
            echo "\n";
        }
    }

    if (!$hasSequence) {
        echo "   ⚠️  ADVERTENCIA: id_tramite podría no tener secuencia automática\n";
    }

    echo "\n📝 Eliminando sp_registro_solicitud anterior si existe...\n";

    // Eliminar la función existente
    DB::statement("DROP FUNCTION IF EXISTS comun.sp_registro_solicitud");

    echo "   ✅ Función anterior eliminada\n\n";

    echo "📝 Creando sp_registro_solicitud...\n\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_registro_solicitud(
            -- Tipo y actividad
            p_tipo_tramite INTEGER,
            p_id_giro INTEGER,
            p_actividad VARCHAR,
            -- Datos del propietario
            p_propietario VARCHAR,
            p_telefono VARCHAR,
            p_email VARCHAR,
            -- Ubicación
            p_calle VARCHAR,
            p_colonia VARCHAR,
            p_cp VARCHAR,
            p_numext VARCHAR,
            p_numint VARCHAR,
            p_letraext VARCHAR,
            p_letraint VARCHAR,
            p_zona INTEGER,
            p_subzona INTEGER,
            -- Datos técnicos
            p_sup_const NUMERIC,
            p_sup_autorizada NUMERIC,
            p_num_cajones INTEGER,
            p_num_empleados INTEGER,
            p_inversion NUMERIC,
            -- Identificación
            p_rfc VARCHAR,
            p_curp VARCHAR,
            -- Observaciones
            p_especificaciones TEXT,
            -- Control
            p_usuario VARCHAR
        )
        RETURNS TABLE(
            id_tramite INTEGER,
            folio INTEGER,
            mensaje VARCHAR
        ) AS \$\$
        DECLARE
            v_id_tramite INTEGER;
            v_folio INTEGER;
            v_fecha_actual DATE;
        BEGIN
            -- Obtener fecha actual
            v_fecha_actual := CURRENT_DATE;

            -- Insertar el nuevo trámite
            -- Restricciones de longitud de la tabla:
            -- tipo_tramite: char(2), actividad: char(130), propietario: char(80)
            -- telefono_prop: char(30), ubicacion: char(50), colonia_ubic: char(25)
            -- capturista: char(10), estatus: char(1)
            INSERT INTO comun.tramites (
                tipo_tramite,
                id_giro,
                actividad,
                propietario,
                telefono_prop,
                email,
                ubicacion,
                colonia_ubic,
                cp,
                numext_ubic,
                numint_ubic,
                letraext_ubic,
                letraint_ubic,
                zona,
                subzona,
                sup_construida,
                sup_autorizada,
                num_cajones,
                num_empleados,
                inversion,
                rfc,
                curp,
                observaciones,
                estatus,
                feccap,
                capturista
            ) VALUES (
                LPAD(p_tipo_tramite::TEXT, 2, '0')::CHAR(2),  -- Convertir INT a CHAR(2) con padding
                p_id_giro,
                SUBSTR(p_actividad, 1, 130)::CHAR(130),  -- Truncar a 130 chars
                SUBSTR(p_propietario, 1, 80)::CHAR(80),  -- Truncar a 80 chars
                SUBSTR(p_telefono, 1, 30)::CHAR(30),  -- Truncar a 30 chars
                p_email,
                SUBSTR(p_calle, 1, 50)::CHAR(50),  -- ubicacion - truncar a 50 chars
                SUBSTR(p_colonia, 1, 25)::CHAR(25),  -- Truncar a 25 chars
                CASE WHEN p_cp IS NOT NULL AND p_cp <> '' THEN p_cp::INTEGER ELSE NULL END,
                CASE WHEN p_numext IS NOT NULL AND p_numext <> '' THEN p_numext::INTEGER ELSE NULL END,
                p_numint,
                p_letraext,
                p_letraint,
                CASE WHEN p_zona IS NOT NULL THEN p_zona::SMALLINT ELSE NULL END,
                CASE WHEN p_subzona IS NOT NULL THEN p_subzona::SMALLINT ELSE NULL END,
                p_sup_const,
                p_sup_autorizada,
                CASE WHEN p_num_cajones IS NOT NULL THEN p_num_cajones::SMALLINT ELSE NULL END,
                CASE WHEN p_num_empleados IS NOT NULL THEN p_num_empleados::SMALLINT ELSE NULL END,
                p_inversion,
                p_rfc,
                p_curp,
                p_especificaciones,
                'T'::CHAR(1),  -- Estatus = En Trámite (char(1))
                v_fecha_actual,
                SUBSTR(p_usuario, 1, 10)::CHAR(10)  -- capturista - truncar a 10 chars
            )
            RETURNING comun.tramites.id_tramite, comun.tramites.folio
            INTO v_id_tramite, v_folio;

            -- Retornar los datos del trámite creado
            RETURN QUERY
            SELECT
                v_id_tramite,
                v_folio,
                CAST('Solicitud registrada exitosamente' AS VARCHAR);

        EXCEPTION
            WHEN OTHERS THEN
                RAISE EXCEPTION 'Error al registrar solicitud: %', SQLERRM;
        END;
        \$\$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_registro_solicitud creado exitosamente\n\n";

    // Hacer una prueba del SP
    echo "🧪 Realizando prueba de inserción...\n";

    try {
        $testResult = DB::select("
            SELECT * FROM comun.sp_registro_solicitud(
                p_tipo_tramite := 1,
                p_id_giro := 1,
                p_actividad := 'TEST - Actividad de prueba desde PHP',
                p_propietario := 'TEST - Propietario de Prueba',
                p_telefono := '33-1234-5678',
                p_email := 'test@ejemplo.com',
                p_calle := 'Calle de Prueba',
                p_colonia := 'Colonia de Prueba',
                p_cp := '44100',
                p_numext := '123',
                p_numint := NULL,
                p_letraext := NULL,
                p_letraint := NULL,
                p_zona := 1,
                p_subzona := 1,
                p_sup_const := 100.00,
                p_sup_autorizada := 100.00,
                p_num_cajones := 2,
                p_num_empleados := 5,
                p_inversion := 50000.00,
                p_rfc := 'XAXX010101000',
                p_curp := 'XAXX010101HDFXXX00',
                p_especificaciones := 'Registro de prueba desde script PHP',
                p_usuario := 'TEST_DEPLOY'
            )
        ");

        if (count($testResult) > 0) {
            $result = $testResult[0];
            echo "\n✅ PRUEBA EXITOSA\n";
            echo "   ID Trámite creado: " . $result->id_tramite . "\n";
            echo "   Folio asignado: " . $result->folio . "\n";
            echo "   Mensaje: " . $result->mensaje . "\n\n";

            // Eliminar el registro de prueba
            echo "🗑️  Eliminando registro de prueba...\n";
            DB::delete("DELETE FROM comun.tramites WHERE id_tramite = ?", [$result->id_tramite]);
            echo "   ✅ Registro de prueba eliminado\n\n";
        }

    } catch (Exception $e) {
        echo "\n❌ ERROR en prueba: " . $e->getMessage() . "\n\n";
        echo "⚠️  El SP fue creado pero la prueba falló. Posibles causas:\n";
        echo "   - Campos requeridos faltantes en la tabla\n";
        echo "   - Restricciones de foreign keys\n";
        echo "   - Secuencias no configuradas para id_tramite o folio\n\n";
    }

    echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
    echo "║                            ✅ DESPLIEGUE COMPLETADO                          ║\n";
    echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

    echo "SP Creado:\n";
    echo "  ✅ comun.sp_registro_solicitud - Crear nueva solicitud de trámite (INSERT)\n\n";
    echo "Funcionalidad:\n";
    echo "  • Inserta nuevo registro en comun.tramites con estatus 'T' (En Trámite)\n";
    echo "  • Genera automáticamente id_tramite y folio (si tienen secuencia)\n";
    echo "  • Registra fecha de captura y usuario\n";
    echo "  • Retorna id_tramite, folio y mensaje de confirmación\n\n";

    echo "Servidor: 192.168.6.146\n";
    echo "Base de datos: padron_licencias\n";
    echo "Esquema: comun\n\n";

} catch (Exception $e) {
    echo "\n❌ ERROR CRÍTICO: " . $e->getMessage() . "\n\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
