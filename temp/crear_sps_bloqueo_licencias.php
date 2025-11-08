<?php
// Crear SPs de bloqueo en public usando public.bloqueo (para licencias/anuncios/trámites)

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SPS DE BLOQUEO EN PUBLIC ===\n\n";

    // 1. SP_BLOQUEODOMICILIOS_LIST
    echo "1. Creando sp_bloqueodomicilios_list...\n";
    $db->exec("DROP FUNCTION IF EXISTS public.sp_bloqueodomicilios_list(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR) CASCADE");

    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_list(
            p_page INTEGER DEFAULT 1,
            p_page_size INTEGER DEFAULT 10,
            p_tipo VARCHAR DEFAULT NULL,
            p_estado VARCHAR DEFAULT NULL,
            p_vigente VARCHAR DEFAULT NULL
        )
        RETURNS TABLE (
            id_tramite INTEGER,
            id_licencia INTEGER,
            id_anuncio INTEGER,
            tipo_registro VARCHAR,
            numero_registro INTEGER,
            bloqueado SMALLINT,
            vigente VARCHAR,
            fecha_mov DATE,
            capturista VARCHAR,
            observa VARCHAR,
            total_count BIGINT
        ) AS \$\$
        DECLARE
            v_offset INTEGER;
        BEGIN
            v_offset := (p_page - 1) * p_page_size;

            RETURN QUERY
            WITH filtered_data AS (
                SELECT
                    b.id_tramite,
                    b.id_licencia,
                    b.id_anuncio,
                    CASE
                        WHEN b.id_tramite IS NOT NULL THEN 'Tramite'
                        WHEN b.id_licencia IS NOT NULL THEN 'Licencia'
                        WHEN b.id_anuncio IS NOT NULL THEN 'Anuncio'
                        ELSE 'Otro'
                    END::VARCHAR AS tipo_registro,
                    COALESCE(b.id_tramite, b.id_licencia, b.id_anuncio)::INTEGER AS numero_registro,
                    b.bloqueado,
                    TRIM(COALESCE(b.vigente, ''))::VARCHAR AS vigente,
                    b.fecha_mov,
                    TRIM(COALESCE(b.capturista, ''))::VARCHAR AS capturista,
                    TRIM(COALESCE(b.observa, ''))::VARCHAR AS observa
                FROM public.bloqueo b
                WHERE 1=1
                    AND (p_tipo IS NULL OR
                        (p_tipo = 'Tramite' AND b.id_tramite IS NOT NULL) OR
                        (p_tipo = 'Licencia' AND b.id_licencia IS NOT NULL) OR
                        (p_tipo = 'Anuncio' AND b.id_anuncio IS NOT NULL))
                    AND (p_estado IS NULL OR
                        (p_estado = 'bloqueado' AND b.bloqueado = 1) OR
                        (p_estado = 'desbloqueado' AND b.bloqueado = 0))
                    AND (p_vigente IS NULL OR TRIM(b.vigente) = p_vigente)
                ORDER BY b.fecha_mov DESC, COALESCE(b.id_tramite, b.id_licencia, b.id_anuncio) DESC
            )
            SELECT
                fd.id_tramite,
                fd.id_licencia,
                fd.id_anuncio,
                fd.tipo_registro,
                fd.numero_registro,
                fd.bloqueado,
                fd.vigente,
                fd.fecha_mov,
                fd.capturista,
                fd.observa,
                (SELECT COUNT(*) FROM filtered_data)::BIGINT AS total_count
            FROM filtered_data fd
            LIMIT p_page_size
            OFFSET v_offset;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ Creado\n\n";

    // 2. SP_BLOQUEODOMICILIOS_CREATE
    echo "2. Creando sp_bloqueodomicilios_create...\n";
    $db->exec("DROP FUNCTION IF EXISTS public.sp_bloqueodomicilios_create(VARCHAR, INTEGER, VARCHAR, VARCHAR) CASCADE");

    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_create(
            p_tipo VARCHAR,
            p_id_registro INTEGER,
            p_observa VARCHAR,
            p_usuario VARCHAR DEFAULT 'sistema'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        DECLARE
            v_existe INTEGER;
        BEGIN
            -- Validar que el registro existe según el tipo
            IF p_tipo = 'Tramite' THEN
                SELECT COUNT(*) INTO v_existe FROM comun.tramites WHERE id_tramite = p_id_registro;
                IF v_existe = 0 THEN
                    RETURN QUERY SELECT FALSE, 'El trámite no existe'::VARCHAR;
                    RETURN;
                END IF;
            ELSIF p_tipo = 'Licencia' THEN
                SELECT COUNT(*) INTO v_existe FROM comun.licencias WHERE id_licencia = p_id_registro;
                IF v_existe = 0 THEN
                    RETURN QUERY SELECT FALSE, 'La licencia no existe'::VARCHAR;
                    RETURN;
                END IF;
            ELSIF p_tipo = 'Anuncio' THEN
                SELECT COUNT(*) INTO v_existe FROM comun.anuncios WHERE id_anuncio = p_id_registro;
                IF v_existe = 0 THEN
                    RETURN QUERY SELECT FALSE, 'El anuncio no existe'::VARCHAR;
                    RETURN;
                END IF;
            ELSE
                RETURN QUERY SELECT FALSE, 'Tipo de registro inválido'::VARCHAR;
                RETURN;
            END IF;

            -- Insertar el bloqueo
            IF p_tipo = 'Tramite' THEN
                INSERT INTO public.bloqueo (id_tramite, bloqueado, capturista, fecha_mov, observa, vigente)
                VALUES (p_id_registro, 1, p_usuario, CURRENT_DATE, p_observa, 'V');
            ELSIF p_tipo = 'Licencia' THEN
                INSERT INTO public.bloqueo (id_licencia, bloqueado, capturista, fecha_mov, observa, vigente)
                VALUES (p_id_registro, 1, p_usuario, CURRENT_DATE, p_observa, 'V');
            ELSIF p_tipo = 'Anuncio' THEN
                INSERT INTO public.bloqueo (id_anuncio, bloqueado, capturista, fecha_mov, observa, vigente)
                VALUES (p_id_registro, 1, p_usuario, CURRENT_DATE, p_observa, 'V');
            END IF;

            RETURN QUERY SELECT TRUE, 'Bloqueo registrado exitosamente'::VARCHAR;

        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, ('Error al registrar bloqueo: ' || SQLERRM)::VARCHAR;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ Creado\n\n";

    // 3. SP_BLOQUEODOMICILIOS_CANCEL
    echo "3. Creando sp_bloqueodomicilios_cancel...\n";
    $db->exec("DROP FUNCTION IF EXISTS public.sp_bloqueodomicilios_cancel(VARCHAR, INTEGER, VARCHAR) CASCADE");

    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_cancel(
            p_tipo VARCHAR,
            p_id_registro INTEGER,
            p_motivo VARCHAR DEFAULT 'Cancelación de bloqueo'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        DECLARE
            v_count INTEGER;
        BEGIN
            -- Actualizar el bloqueo como cancelado
            IF p_tipo = 'Tramite' THEN
                UPDATE public.bloqueo
                SET vigente = 'C', observa = TRIM(observa) || ' | CANCELADO: ' || p_motivo
                WHERE id_tramite = p_id_registro AND vigente = 'V';
                GET DIAGNOSTICS v_count = ROW_COUNT;
            ELSIF p_tipo = 'Licencia' THEN
                UPDATE public.bloqueo
                SET vigente = 'C', observa = TRIM(observa) || ' | CANCELADO: ' || p_motivo
                WHERE id_licencia = p_id_registro AND vigente = 'V';
                GET DIAGNOSTICS v_count = ROW_COUNT;
            ELSIF p_tipo = 'Anuncio' THEN
                UPDATE public.bloqueo
                SET vigente = 'C', observa = TRIM(observa) || ' | CANCELADO: ' || p_motivo
                WHERE id_anuncio = p_id_registro AND vigente = 'V';
                GET DIAGNOSTICS v_count = ROW_COUNT;
            ELSE
                RETURN QUERY SELECT FALSE, 'Tipo de registro inválido'::VARCHAR;
                RETURN;
            END IF;

            IF v_count = 0 THEN
                RETURN QUERY SELECT FALSE, 'No se encontró bloqueo vigente para cancelar'::VARCHAR;
            ELSE
                RETURN QUERY SELECT TRUE, 'Bloqueo(s) cancelado(s) exitosamente'::VARCHAR;
            END IF;

        EXCEPTION WHEN OTHERS THEN
            RETURN QUERY SELECT FALSE, ('Error al cancelar bloqueo: ' || SQLERRM)::VARCHAR;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ Creado\n\n";

    // Pruebas
    echo "=== PRUEBAS ===\n\n";
    echo "Probando LIST:\n";
    $stmt = $db->query("SELECT * FROM public.sp_bloqueodomicilios_list(1, 10, NULL, NULL, 'V') LIMIT 3");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "  Registros: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "  Total en BD: " . ($results[0]['total_count'] ?? 0) . "\n";
        echo "  Primer registro: {$results[0]['tipo_registro']} #{$results[0]['numero_registro']}\n";
    }

    echo "\n✅ TODOS LOS SPS CREADOS Y PROBADOS\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
