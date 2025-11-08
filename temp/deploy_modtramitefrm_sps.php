<?php
/**
 * Script para desplegar todos los SPs de modtramitefrm
 * Componente: Modificación de Trámites
 * Prioridad: P1 - CRÍTICA
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
echo "║              DESPLIEGUE DE SPs - MODTRAMITEFRM (P1 - CRÍTICA)               ║\n";
echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

try {
    // ============================================================================
    // SP 1: sp_get_tramite_by_id
    // Obtiene datos completos de un trámite por su ID
    // ============================================================================
    echo "📝 [1/6] Creando sp_get_tramite_by_id...\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_get_tramite_by_id(p_id_tramite INTEGER)
        RETURNS TABLE(
            id_tramite INTEGER,
            folio INTEGER,
            tipo_tramite VARCHAR,
            id_giro INTEGER,
            giro_descripcion VARCHAR,
            zona SMALLINT,
            subzona SMALLINT,
            actividad VARCHAR,
            cvecuenta INTEGER,
            recaud SMALLINT,
            licencia_ref INTEGER,
            tramita_apoderado VARCHAR,
            propietario VARCHAR,
            primer_ap VARCHAR,
            segundo_ap VARCHAR,
            rfc VARCHAR,
            curp VARCHAR,
            domicilio VARCHAR,
            numext_prop INTEGER,
            numint_prop VARCHAR,
            colonia_prop VARCHAR,
            telefono_prop VARCHAR,
            email VARCHAR,
            cvecalle INTEGER,
            ubicacion VARCHAR,
            numext_ubic INTEGER,
            numint_ubic VARCHAR,
            letraext_ubic VARCHAR,
            letraint_ubic VARCHAR,
            colonia_ubic VARCHAR,
            espubic VARCHAR,
            sup_construida NUMERIC,
            sup_autorizada NUMERIC,
            num_cajones SMALLINT,
            num_empleados SMALLINT,
            aforo SMALLINT,
            inversion NUMERIC,
            rhorario VARCHAR,
            cp INTEGER,
            estatus VARCHAR,
            feccap DATE,
            capturista VARCHAR,
            observaciones TEXT,
            bloqueado SMALLINT,
            dictamen SMALLINT
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT
                t.id_tramite,
                t.folio,
                CAST(t.tipo_tramite AS VARCHAR),
                t.id_giro,
                CAST('' AS VARCHAR) as giro_descripcion,
                t.zona,
                t.subzona,
                CAST(t.actividad AS VARCHAR),
                t.cvecuenta,
                t.recaud,
                t.licencia_ref,
                t.tramita_apoderado,
                CAST(t.propietario AS VARCHAR),
                t.primer_ap,
                t.segundo_ap,
                CAST(t.rfc AS VARCHAR),
                CAST(t.curp AS VARCHAR),
                CAST(t.domicilio AS VARCHAR),
                t.numext_prop,
                CAST(t.numint_prop AS VARCHAR),
                CAST(t.colonia_prop AS VARCHAR),
                CAST(t.telefono_prop AS VARCHAR),
                CAST(t.email AS VARCHAR),
                t.cvecalle,
                CAST(t.ubicacion AS VARCHAR),
                t.numext_ubic,
                CAST(t.numint_ubic AS VARCHAR),
                CAST(t.letraext_ubic AS VARCHAR),
                CAST(t.letraint_ubic AS VARCHAR),
                CAST(t.colonia_ubic AS VARCHAR),
                CAST(t.espubic AS VARCHAR),
                t.sup_construida,
                t.sup_autorizada,
                t.num_cajones,
                t.num_empleados,
                t.aforo,
                t.inversion,
                CAST(t.rhorario AS VARCHAR),
                t.cp,
                CAST(t.estatus AS VARCHAR),
                t.feccap,
                CAST(t.capturista AS VARCHAR),
                t.observaciones,
                t.bloqueado,
                t.dictamen
            FROM comun.tramites t
            WHERE t.id_tramite = p_id_tramite;
        END;
        $$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_get_tramite_by_id creado exitosamente\n\n";

    // ============================================================================
    // SP 2: sp_get_giro_by_id
    // Obtiene descripción de un giro por su ID
    // ============================================================================
    echo "📝 [2/6] Creando sp_get_giro_by_id...\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_get_giro_by_id(p_id_giro INTEGER)
        RETURNS TABLE(
            id_giro INTEGER,
            descripcion VARCHAR,
            tipo VARCHAR,
            vigente VARCHAR
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT DISTINCT ON (g.id_giro)
                g.id_giro,
                CAST(g.descripcion AS VARCHAR),
                CAST(g.tipo AS VARCHAR),
                CAST(g.vigente AS VARCHAR)
            FROM comun.c_giros g
            WHERE g.id_giro = p_id_giro
            ORDER BY g.id_giro, g.descripcion DESC
            LIMIT 1;
        END;
        $$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_get_giro_by_id creado exitosamente\n\n";

    // ============================================================================
    // SP 3: sp_update_tramite
    // Actualiza todos los campos modificables de un trámite
    // ============================================================================
    echo "📝 [3/6] Creando sp_update_tramite...\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_update_tramite(
            p_id_tramite INTEGER,
            -- Datos del propietario
            p_primer_ap VARCHAR,
            p_segundo_ap VARCHAR,
            p_propietario VARCHAR,
            p_rfc VARCHAR,
            p_curp VARCHAR,
            p_telefono_prop VARCHAR,
            p_email VARCHAR,
            -- Domicilio fiscal
            p_domicilio VARCHAR,
            p_numext_prop INTEGER,
            p_numint_prop VARCHAR,
            p_colonia_prop VARCHAR,
            -- Ubicación del negocio
            p_cvecalle INTEGER,
            p_ubicacion VARCHAR,
            p_numext_ubic INTEGER,
            p_numint_ubic VARCHAR,
            p_letraext_ubic VARCHAR,
            p_letraint_ubic VARCHAR,
            p_colonia_ubic VARCHAR,
            p_espubic VARCHAR,
            p_zona SMALLINT,
            p_subzona SMALLINT,
            p_cp INTEGER,
            -- Giro y actividad
            p_id_giro INTEGER,
            p_actividad VARCHAR,
            -- Datos técnicos
            p_sup_construida NUMERIC,
            p_sup_autorizada NUMERIC,
            p_num_cajones SMALLINT,
            p_num_empleados SMALLINT,
            p_aforo SMALLINT,
            p_inversion NUMERIC,
            p_rhorario VARCHAR,
            -- Observaciones
            p_observaciones TEXT,
            -- Control
            p_usuario VARCHAR
        )
        RETURNS JSON AS $$
        DECLARE
            v_estatus VARCHAR;
            v_result JSON;
        BEGIN
            -- Verificar que el trámite existe
            SELECT estatus INTO v_estatus
            FROM comun.tramites
            WHERE id_tramite = p_id_tramite;

            IF NOT FOUND THEN
                RETURN json_build_object(
                    'success', false,
                    'message', 'El trámite no existe'
                );
            END IF;

            -- Verificar que el trámite se puede modificar
            IF v_estatus NOT IN ('T', 'R') THEN
                RETURN json_build_object(
                    'success', false,
                    'message', 'Solo se pueden modificar trámites en proceso (T) o rechazados (R). Estatus actual: ' || v_estatus
                );
            END IF;

            -- Actualizar el trámite
            UPDATE comun.tramites SET
                -- Datos del propietario
                primer_ap = p_primer_ap,
                segundo_ap = p_segundo_ap,
                propietario = p_propietario,
                rfc = p_rfc,
                curp = p_curp,
                telefono_prop = p_telefono_prop,
                email = p_email,
                -- Domicilio fiscal
                domicilio = p_domicilio,
                numext_prop = p_numext_prop,
                numint_prop = p_numint_prop,
                colonia_prop = p_colonia_prop,
                -- Ubicación del negocio
                cvecalle = p_cvecalle,
                ubicacion = p_ubicacion,
                numext_ubic = p_numext_ubic,
                numint_ubic = p_numint_ubic,
                letraext_ubic = p_letraext_ubic,
                letraint_ubic = p_letraint_ubic,
                colonia_ubic = p_colonia_ubic,
                espubic = p_espubic,
                zona = p_zona,
                subzona = p_subzona,
                cp = p_cp,
                -- Giro y actividad
                id_giro = p_id_giro,
                actividad = p_actividad,
                -- Datos técnicos
                sup_construida = p_sup_construida,
                sup_autorizada = p_sup_autorizada,
                num_cajones = p_num_cajones,
                num_empleados = p_num_empleados,
                aforo = p_aforo,
                inversion = p_inversion,
                rhorario = p_rhorario,
                -- Observaciones
                observaciones = p_observaciones
            WHERE id_tramite = p_id_tramite;

            RETURN json_build_object(
                'success', true,
                'message', 'Trámite actualizado correctamente',
                'id_tramite', p_id_tramite
            );

        EXCEPTION
            WHEN OTHERS THEN
                RETURN json_build_object(
                    'success', false,
                    'message', 'Error al actualizar trámite: ' || SQLERRM
                );
        END;
        $$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_update_tramite creado exitosamente\n\n";

    // ============================================================================
    // SP 4: sp_get_giros_search
    // Búsqueda de giros para selección
    // ============================================================================
    echo "📝 [4/6] Creando sp_get_giros_search...\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_get_giros_search(
            p_busqueda VARCHAR DEFAULT NULL,
            p_tipo VARCHAR DEFAULT NULL,
            p_limit INTEGER DEFAULT 50
        )
        RETURNS TABLE(
            id_giro INTEGER,
            descripcion VARCHAR,
            tipo VARCHAR,
            vigente VARCHAR,
            clasificacion VARCHAR
        ) AS $$
        BEGIN
            RETURN QUERY
            SELECT DISTINCT ON (g.id_giro)
                g.id_giro,
                CAST(g.descripcion AS VARCHAR),
                CAST(g.tipo AS VARCHAR),
                CAST(g.vigente AS VARCHAR),
                CAST(g.clasificacion AS VARCHAR)
            FROM comun.c_giros g
            WHERE g.vigente = 'V'
                AND (p_busqueda IS NULL OR CAST(g.descripcion AS TEXT) ILIKE '%' || p_busqueda || '%')
                AND (p_tipo IS NULL OR g.tipo = p_tipo)
            ORDER BY g.id_giro, g.descripcion DESC
            LIMIT p_limit;
        END;
        $$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_get_giros_search creado exitosamente\n\n";

    // ============================================================================
    // SP 5: sp_get_calles_search
    // Búsqueda de calles para selección
    // ============================================================================
    echo "📝 [5/6] Creando sp_get_calles_search...\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_get_calles_search(
            p_busqueda VARCHAR,
            p_limit INTEGER DEFAULT 50
        )
        RETURNS TABLE(
            cvecalle INTEGER,
            calle VARCHAR,
            zona SMALLINT,
            subzona SMALLINT
        ) AS $$
        BEGIN
            -- Intentar obtener calles desde c_callesqry si existe
            RETURN QUERY
            SELECT DISTINCT
                c.cvecalle::INTEGER,
                CAST(c.calle AS VARCHAR),
                c.zona::SMALLINT,
                c.subzona::SMALLINT
            FROM comun.c_callesqry c
            WHERE CAST(c.calle AS TEXT) ILIKE '%' || p_busqueda || '%'
            ORDER BY c.calle
            LIMIT p_limit;

        EXCEPTION
            WHEN OTHERS THEN
                -- Si no existe la tabla, retornar vacío
                RETURN;
        END;
        $$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_get_calles_search creado exitosamente\n\n";

    // ============================================================================
    // SP 6: sp_get_colonias_search
    // Búsqueda de colonias para selección
    // ============================================================================
    echo "📝 [6/6] Creando sp_get_colonias_search...\n";

    DB::statement("
        CREATE OR REPLACE FUNCTION comun.sp_get_colonias_search(
            p_busqueda VARCHAR,
            p_limit INTEGER DEFAULT 50
        )
        RETURNS TABLE(
            colonia VARCHAR,
            cp INTEGER
        ) AS $$
        BEGIN
            -- Intentar obtener colonias desde cp_correos si existe
            RETURN QUERY
            SELECT DISTINCT
                CAST(c.colonia AS VARCHAR),
                c.cp::INTEGER
            FROM comun.cp_correos c
            WHERE CAST(c.colonia AS TEXT) ILIKE '%' || p_busqueda || '%'
            ORDER BY c.colonia
            LIMIT p_limit;

        EXCEPTION
            WHEN OTHERS THEN
                -- Si no existe la tabla, retornar vacío
                RETURN;
        END;
        $$ LANGUAGE plpgsql;
    ");

    echo "   ✅ SP sp_get_colonias_search creado exitosamente\n\n";

    // ============================================================================
    // RESUMEN
    // ============================================================================
    echo "╔══════════════════════════════════════════════════════════════════════════════╗\n";
    echo "║                            ✅ DESPLIEGUE COMPLETADO                          ║\n";
    echo "╚══════════════════════════════════════════════════════════════════════════════╝\n\n";

    echo "SPs Creados:\n";
    echo "  ✅ comun.sp_get_tramite_by_id       - Obtener trámite completo\n";
    echo "  ✅ comun.sp_get_giro_by_id          - Obtener descripción del giro\n";
    echo "  ✅ comun.sp_update_tramite          - Actualizar trámite (PRINCIPAL)\n";
    echo "  ✅ comun.sp_get_giros_search        - Búsqueda de giros\n";
    echo "  ✅ comun.sp_get_calles_search       - Búsqueda de calles\n";
    echo "  ✅ comun.sp_get_colonias_search     - Búsqueda de colonias\n\n";

    echo "Servidor: 192.168.6.146\n";
    echo "Base de datos: padron_licencias\n";
    echo "Esquema: comun\n\n";

    echo "✅ Todos los SPs desplegados exitosamente\n";

} catch (Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
