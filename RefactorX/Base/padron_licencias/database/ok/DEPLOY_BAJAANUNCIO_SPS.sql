-- ============================================================================
-- DEPLOY: Stored Procedures para Baja de Anuncios
-- Schema: comun
-- Database: padron_licencias
-- Fecha: 2025-11-08
-- Descripción: SPs para búsqueda, consulta y baja de anuncios publicitarios
-- ============================================================================

-- Drop functions if exist (para permitir re-deploy)
DROP FUNCTION IF EXISTS comun.sp_bajaanun_buscar_anuncio(INTEGER);
DROP FUNCTION IF EXISTS comun.sp_bajaanun_obtener_info(INTEGER);
DROP FUNCTION IF EXISTS comun.sp_bajaanun_ejecutar(INTEGER, TEXT, INTEGER, INTEGER, BOOLEAN, TEXT);

-- ============================================================================
-- FUNCTION: sp_bajaanun_buscar_anuncio
-- Descripción: Busca un anuncio por número para dar de baja
-- Retorna: Información completa del anuncio
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_bajaanun_buscar_anuncio(
    p_anuncio INTEGER
)
RETURNS TABLE (
    -- ID
    id_anuncio INTEGER,
    anuncio INTEGER,
    id_licencia INTEGER,
    licencia INTEGER,

    -- Estado
    vigente VARCHAR,
    bloqueado SMALLINT,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,

    -- Información del anuncio
    texto_anuncio VARCHAR,
    misma_forma VARCHAR,
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    num_caras SMALLINT,

    -- Ubicación
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    numint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    espubic VARCHAR,

    -- Giro
    id_giro INTEGER,
    descripcion_giro VARCHAR,

    -- Información de la licencia ligada
    propietario_licencia VARCHAR,

    -- Fechas
    fecha_otorgamiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        -- ID
        a.id_anuncio,
        a.anuncio,
        a.id_licencia,
        l.licencia,

        -- Estado
        TRIM(a.vigente)::VARCHAR,
        a.bloqueado,
        a.fecha_baja,
        a.axo_baja,
        a.folio_baja,

        -- Información del anuncio
        TRIM(COALESCE(a.texto_anuncio, ''))::VARCHAR,
        TRIM(COALESCE(a.misma_forma, ''))::VARCHAR,
        a.medidas1,
        a.medidas2,
        a.num_caras,

        -- Ubicación
        TRIM(COALESCE(a.ubicacion, ''))::VARCHAR,
        a.numext_ubic,
        TRIM(COALESCE(a.numint_ubic, ''))::VARCHAR,
        TRIM(COALESCE(a.colonia_ubic, ''))::VARCHAR,
        TRIM(COALESCE(a.espubic, ''))::VARCHAR,

        -- Giro
        a.id_giro,
        TRIM(COALESCE(g.descripcion, ''))::VARCHAR,

        -- Información de la licencia
        TRIM(COALESCE(l.propietario, ''))::VARCHAR,

        -- Fechas
        a.fecha_otorgamiento
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
    LEFT JOIN comun.c_giros g ON g.id_giro = a.id_giro
    WHERE a.anuncio = p_anuncio;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: sp_bajaanun_obtener_info
-- Descripción: Obtiene información adicional del anuncio (fabricante, etc)
-- Retorna: Info complementaria
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_bajaanun_obtener_info(
    p_id_anuncio INTEGER
)
RETURNS TABLE (
    id_fabricante INTEGER,
    observaciones VARCHAR,
    superficie_total NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_fabricante,
        TRIM(COALESCE(a.espubic, ''))::VARCHAR AS observaciones,
        (a.medidas1 * a.medidas2)::NUMERIC AS superficie_total
    FROM comun.anuncios a
    WHERE a.id_anuncio = p_id_anuncio;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: sp_bajaanun_ejecutar
-- Descripción: Ejecuta la baja de un anuncio publicitario
-- Retorna: success (boolean) y message (text)
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_bajaanun_ejecutar(
    p_anuncio INTEGER,
    p_motivo TEXT,
    p_anio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_baja_error BOOLEAN DEFAULT FALSE,
    p_usuario TEXT DEFAULT 'sistema'
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_anuncio RECORD;
    v_id_anuncio INTEGER;
    v_id_licencia INTEGER;
BEGIN
    -- Buscar el anuncio por número
    SELECT * INTO v_anuncio
    FROM comun.anuncios
    WHERE anuncio = p_anuncio;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Anuncio no encontrado.';
        RETURN;
    END IF;

    v_id_anuncio := v_anuncio.id_anuncio;
    v_id_licencia := v_anuncio.id_licencia;

    -- Validar que el anuncio esté vigente
    IF TRIM(v_anuncio.vigente) <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya está dado de baja o cancelado.';
        RETURN;
    END IF;

    -- Validar que el anuncio no esté bloqueado
    IF v_anuncio.bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio está bloqueado. No se puede dar de baja.';
        RETURN;
    END IF;

    -- Cancelar adeudos del anuncio (cvepago = 999999 indica cancelado por baja)
    UPDATE comun.detsal_lic
    SET cvepago = 999999
    WHERE id_anuncio = v_id_anuncio
      AND cvepago = 0;

    -- Dar de baja el anuncio
    UPDATE comun.anuncios
    SET vigente = 'C',
        fecha_baja = CURRENT_DATE,
        axo_baja = p_anio,
        folio_baja = p_folio,
        espubic = p_motivo
    WHERE id_anuncio = v_id_anuncio;

    -- Recalcular saldo de la licencia si existe la función calc_sdosl
    IF v_id_licencia IS NOT NULL THEN
        BEGIN
            PERFORM comun.calc_sdosl(v_id_licencia);
        EXCEPTION WHEN OTHERS THEN
            -- Si no existe la función, continuar sin error
            NULL;
        END;
    END IF;

    -- Registrar en bitácora si la tabla existe
    BEGIN
        INSERT INTO comun.anun_bajas_bitacora(
            id_anuncio,
            anuncio,
            id_licencia,
            usuario,
            fecha,
            motivo,
            anio,
            folio,
            baja_error
        )
        VALUES (
            v_id_anuncio,
            p_anuncio,
            v_id_licencia,
            p_usuario,
            CURRENT_TIMESTAMP,
            p_motivo,
            p_anio,
            p_folio,
            p_baja_error
        );
    EXCEPTION WHEN OTHERS THEN
        -- Si la tabla de bitácora no existe, continuar sin error
        NULL;
    END;

    -- Mensaje de éxito
    RETURN QUERY SELECT TRUE, 'Anuncio #' || p_anuncio || ' dado de baja correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Mensajes de confirmación
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✓ comun.sp_bajaanun_buscar_anuncio creado correctamente';
    RAISE NOTICE '✓ comun.sp_bajaanun_obtener_info creado correctamente';
    RAISE NOTICE '✓ comun.sp_bajaanun_ejecutar creado correctamente';
    RAISE NOTICE '✓ Instalación completada exitosamente';
END $$;
