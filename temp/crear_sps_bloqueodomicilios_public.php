<?php
// Crear SPs de bloqueo de domicilios en el esquema public
// Adaptados a la estructura de public.bloqueo_dom

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== CREAR SPS DE BLOQUEO DOMICILIOS EN PUBLIC ===\n\n";

    // 1. SP_BLOQUEODOMICILIOS_LIST
    echo "1️⃣  Creando sp_bloqueodomicilios_list...\n";

    // Eliminar si existe
    $db->exec("DROP FUNCTION IF EXISTS public.sp_bloqueodomicilios_list(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR) CASCADE");

    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_list(
            p_page INTEGER DEFAULT 1,
            p_page_size INTEGER DEFAULT 25,
            p_tipo VARCHAR DEFAULT NULL,
            p_estado VARCHAR DEFAULT NULL,
            p_vigente VARCHAR DEFAULT 'V'
        )
        RETURNS TABLE (
            cvecuenta INTEGER,
            cvecalle INTEGER,
            calle VARCHAR,
            num_ext INTEGER,
            let_ext VARCHAR,
            num_int INTEGER,
            let_int VARCHAR,
            folio INTEGER,
            fecha DATE,
            vig VARCHAR,
            observacion VARCHAR,
            capturista VARCHAR,
            total_count BIGINT
        ) AS \$\$
        DECLARE
            v_offset INTEGER;
        BEGIN
            v_offset := (p_page - 1) * p_page_size;

            RETURN QUERY
            WITH filtered_data AS (
                SELECT
                    bd.cvecuenta,
                    bd.cvecalle,
                    TRIM(bd.calle)::VARCHAR AS calle,
                    bd.num_ext,
                    TRIM(bd.let_ext)::VARCHAR AS let_ext,
                    bd.num_int,
                    TRIM(bd.let_int)::VARCHAR AS let_int,
                    bd.folio,
                    bd.fecha,
                    TRIM(COALESCE(bd.vig, 'V'))::VARCHAR AS vig,
                    TRIM(COALESCE(bd.observacion, ''))::VARCHAR AS observacion,
                    TRIM(COALESCE(bd.capturista, ''))::VARCHAR AS capturista
                FROM public.bloqueo_dom bd
                WHERE 1=1
                    AND (p_vigente IS NULL OR TRIM(bd.vig) = p_vigente)
                ORDER BY bd.fecha DESC, bd.folio DESC
            )
            SELECT
                fd.cvecuenta,
                fd.cvecalle,
                fd.calle,
                fd.num_ext,
                fd.let_ext,
                fd.num_int,
                fd.let_int,
                fd.folio,
                fd.fecha,
                fd.vig,
                fd.observacion,
                fd.capturista,
                (SELECT COUNT(*) FROM filtered_data)::BIGINT AS total_count
            FROM filtered_data fd
            LIMIT p_page_size
            OFFSET v_offset;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ sp_bloqueodomicilios_list creado\n\n";

    // 2. SP_BLOQUEODOMICILIOS_CREATE
    echo "2️⃣  Creando sp_bloqueodomicilios_create...\n";

    $db->exec("DROP FUNCTION IF EXISTS public.sp_bloqueodomicilios_create(INTEGER, INTEGER, VARCHAR, VARCHAR) CASCADE");

    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_create(
            p_cvecuenta INTEGER,
            p_cvecalle INTEGER,
            p_observacion VARCHAR,
            p_usuario VARCHAR DEFAULT 'sistema'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR,
            folio INTEGER
        ) AS \$\$
        DECLARE
            v_folio INTEGER;
            v_calle VARCHAR;
            v_num_ext INTEGER;
            v_let_ext VARCHAR;
            v_num_int INTEGER;
            v_let_int VARCHAR;
        BEGIN
            -- Obtener el siguiente folio
            SELECT COALESCE(MAX(folio), 0) + 1 INTO v_folio FROM public.bloqueo_dom;

            -- Obtener datos del domicilio desde catastro (simplificado, ajustar según tabla real)
            v_calle := 'PENDIENTE';
            v_num_ext := 0;
            v_let_ext := '';
            v_num_int := 0;
            v_let_int := '';

            -- Insertar el bloqueo
            INSERT INTO public.bloqueo_dom (
                cvecuenta,
                cvecalle,
                calle,
                num_ext,
                let_ext,
                num_int,
                let_int,
                folio,
                fecha,
                hora,
                vig,
                observacion,
                capturista
            ) VALUES (
                p_cvecuenta,
                p_cvecalle,
                v_calle,
                v_num_ext,
                v_let_ext,
                v_num_int,
                v_let_int,
                v_folio,
                CURRENT_DATE,
                CURRENT_TIMESTAMP,
                'V',
                p_observacion,
                p_usuario
            );

            RETURN QUERY SELECT TRUE, 'Bloqueo de domicilio registrado exitosamente'::VARCHAR, v_folio;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al registrar bloqueo: ' || SQLERRM)::VARCHAR, NULL::INTEGER;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ sp_bloqueodomicilios_create creado\n\n";

    // 3. SP_BLOQUEODOMICILIOS_CANCEL
    echo "3️⃣  Creando sp_bloqueodomicilios_cancel...\n";

    $db->exec("DROP FUNCTION IF EXISTS public.sp_bloqueodomicilios_cancel(INTEGER, VARCHAR) CASCADE");

    $db->exec("
        CREATE OR REPLACE FUNCTION public.sp_bloqueodomicilios_cancel(
            p_folio INTEGER,
            p_motivo VARCHAR DEFAULT 'Cancelación de bloqueo'
        )
        RETURNS TABLE (
            success BOOLEAN,
            message VARCHAR
        ) AS \$\$
        DECLARE
            v_count INTEGER;
            v_registro RECORD;
        BEGIN
            -- Verificar que existe el registro
            SELECT * INTO v_registro FROM public.bloqueo_dom WHERE folio = p_folio AND vig = 'V';

            IF NOT FOUND THEN
                RETURN QUERY SELECT FALSE, 'No se encontró bloqueo vigente para cancelar'::VARCHAR;
                RETURN;
            END IF;

            -- Guardar en historial
            INSERT INTO public.h_bloqueo_dom (
                cvecuenta, cvecalle, calle, num_ext, let_ext, num_int, let_int,
                folio, fecha, hora, vig, observacion, capturista,
                fecha_mov, motivo_mov, tipo_mov, modifico
            )
            SELECT
                cvecuenta, cvecalle, calle, num_ext, let_ext, num_int, let_int,
                folio, fecha, hora, vig, observacion, capturista,
                CURRENT_TIMESTAMP, p_motivo, 'CA', capturista
            FROM public.bloqueo_dom
            WHERE folio = p_folio;

            -- Actualizar el bloqueo como cancelado
            UPDATE public.bloqueo_dom
            SET vig = 'C',
                observacion = TRIM(observacion) || ' | CANCELADO: ' || p_motivo
            WHERE folio = p_folio AND vig = 'V';

            GET DIAGNOSTICS v_count = ROW_COUNT;

            IF v_count = 0 THEN
                RETURN QUERY SELECT FALSE, 'No se pudo cancelar el bloqueo'::VARCHAR;
            ELSE
                RETURN QUERY SELECT TRUE, 'Bloqueo cancelado exitosamente'::VARCHAR;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN QUERY SELECT FALSE, ('Error al cancelar bloqueo: ' || SQLERRM)::VARCHAR;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "   ✅ sp_bloqueodomicilios_cancel creado\n\n";

    // Probar los SPs
    echo "=== PRUEBAS ===\n\n";

    echo "🧪 Probando LIST:\n";
    $stmt = $db->query("SELECT * FROM public.sp_bloqueodomicilios_list(1, 10, NULL, NULL, NULL) LIMIT 5");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Registros encontrados: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "   Total en BD: " . ($results[0]['total_count'] ?? 0) . "\n";
    }
    echo "\n";

    echo "✅ TODOS LOS SPS CREADOS EN PUBLIC\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
