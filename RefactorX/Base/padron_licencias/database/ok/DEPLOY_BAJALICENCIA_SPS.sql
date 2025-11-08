-- ============================================================================
-- DEPLOY: Stored Procedures para Baja de Licencias
-- Schema: comun
-- Database: padron_licencias
-- Fecha: 2025-11-08
-- Descripción: SPs para búsqueda, consulta y baja de licencias
-- ============================================================================

-- Drop functions if exist (para permitir re-deploy)
DROP FUNCTION IF EXISTS comun.sp_bajalic_buscar_licencia(INTEGER);
DROP FUNCTION IF EXISTS comun.sp_bajalic_obtener_anuncios(INTEGER);
DROP FUNCTION IF EXISTS comun.sp_bajalic_ejecutar(INTEGER, TEXT, INTEGER, INTEGER, BOOLEAN, TEXT);

-- ============================================================================
-- FUNCTION: sp_bajalic_buscar_licencia
-- Descripción: Busca una licencia por número para dar de baja
-- Retorna: Información completa de la licencia
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_bajalic_buscar_licencia(
    p_licencia INTEGER
)
RETURNS TABLE (
    -- ID
    id_licencia INTEGER,
    licencia INTEGER,

    -- Estado
    vigente VARCHAR,
    bloqueado SMALLINT,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,

    -- Información del propietario
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,

    -- Actividad
    actividad VARCHAR,
    id_giro INTEGER,
    descripcion_giro VARCHAR,

    -- Ubicación
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    numint_ubic VARCHAR,
    colonia_ubic VARCHAR,

    -- Datos técnicos
    sup_construida NUMERIC,
    num_empleados SMALLINT,
    fecha_otorgamiento DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        -- ID
        l.id_licencia,
        l.licencia,

        -- Estado
        TRIM(l.vigente)::VARCHAR,
        l.bloqueado,
        l.fecha_baja,
        l.axo_baja,
        l.folio_baja,

        -- Propietario
        TRIM(l.propietario)::VARCHAR,
        TRIM(l.primer_ap)::VARCHAR,
        TRIM(l.segundo_ap)::VARCHAR,
        TRIM(l.rfc)::VARCHAR,

        -- Actividad
        TRIM(l.actividad)::VARCHAR,
        l.id_giro,
        TRIM(COALESCE(g.descripcion, ''))::VARCHAR,

        -- Ubicación
        TRIM(l.ubicacion)::VARCHAR,
        l.numext_ubic,
        TRIM(l.numint_ubic)::VARCHAR,
        TRIM(l.colonia_ubic)::VARCHAR,

        -- Datos técnicos
        l.sup_construida,
        l.num_empleados,
        l.fecha_otorgamiento
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE l.licencia = p_licencia;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: sp_bajalic_obtener_anuncios
-- Descripción: Obtiene todos los anuncios ligados a una licencia
-- Retorna: Lista de anuncios vigentes y no vigentes
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_bajalic_obtener_anuncios(
    p_id_licencia INTEGER
)
RETURNS TABLE (
    id_anuncio INTEGER,
    anuncio INTEGER,
    vigente VARCHAR,
    bloqueado SMALLINT,
    fecha_otorgamiento DATE,
    fecha_baja DATE,
    texto_anuncio VARCHAR,
    ubicacion VARCHAR,
    espubic VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_anuncio,
        a.anuncio,
        TRIM(a.vigente)::VARCHAR,
        a.bloqueado,
        a.fecha_otorgamiento,
        a.fecha_baja,
        TRIM(COALESCE(a.texto_anuncio, ''))::VARCHAR,
        TRIM(COALESCE(a.ubicacion, ''))::VARCHAR,
        TRIM(COALESCE(a.espubic, ''))::VARCHAR
    FROM comun.anuncios a
    WHERE a.id_licencia = p_id_licencia
    ORDER BY a.anuncio;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: sp_bajalic_ejecutar
-- Descripción: Ejecuta la baja de una licencia y sus anuncios ligados
-- Retorna: success (boolean) y message (text)
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_bajalic_ejecutar(
    p_licencia INTEGER,
    p_motivo TEXT,
    p_anio INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_baja_error BOOLEAN DEFAULT FALSE,
    p_usuario TEXT DEFAULT 'sistema'
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_licencia RECORD;
    v_anuncio RECORD;
    v_id_licencia INTEGER;
    v_count_anuncios INTEGER := 0;
BEGIN
    -- Buscar la licencia por número
    SELECT * INTO v_licencia
    FROM comun.licencias
    WHERE licencia = p_licencia;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Licencia no encontrada.';
        RETURN;
    END IF;

    v_id_licencia := v_licencia.id_licencia;

    -- Validar que la licencia esté vigente
    IF TRIM(v_licencia.vigente) <> 'V' THEN
        RETURN QUERY SELECT FALSE, 'La licencia ya está dada de baja o cancelada.';
        RETURN;
    END IF;

    -- Validar que la licencia no esté bloqueada
    IF v_licencia.bloqueado > 0 AND v_licencia.bloqueado < 5 THEN
        RETURN QUERY SELECT FALSE, 'La licencia está bloqueada. No se puede dar de baja.';
        RETURN;
    END IF;

    -- Verificar anuncios bloqueados
    FOR v_anuncio IN
        SELECT * FROM comun.anuncios
        WHERE id_licencia = v_id_licencia AND TRIM(vigente) = 'V'
    LOOP
        IF v_anuncio.bloqueado > 0 THEN
            RETURN QUERY SELECT FALSE, 'No se puede dar de baja la licencia. El anuncio #' || v_anuncio.anuncio || ' está bloqueado.';
            RETURN;
        END IF;
    END LOOP;

    -- Cancelar adeudos de la licencia (cvepago = 999999 indica cancelado por baja)
    UPDATE comun.detsal_lic
    SET cvepago = 999999
    WHERE id_licencia = v_id_licencia
      AND (id_anuncio IS NULL OR id_anuncio = 0)
      AND cvepago = 0;

    -- Dar de baja anuncios vigentes y cancelar sus adeudos
    FOR v_anuncio IN
        SELECT * FROM comun.anuncios
        WHERE id_licencia = v_id_licencia AND TRIM(vigente) = 'V'
    LOOP
        -- Cancelar adeudos del anuncio
        UPDATE comun.detsal_lic
        SET cvepago = 999999
        WHERE id_anuncio = v_anuncio.id_anuncio
          AND cvepago = 0;

        -- Dar de baja el anuncio
        UPDATE comun.anuncios
        SET vigente = 'C',
            fecha_baja = CURRENT_DATE,
            axo_baja = p_anio,
            folio_baja = p_folio,
            espubic = p_motivo
        WHERE id_anuncio = v_anuncio.id_anuncio;

        v_count_anuncios := v_count_anuncios + 1;
    END LOOP;

    -- Recalcular saldo de la licencia si existe la función calc_sdosl
    BEGIN
        PERFORM comun.calc_sdosl(v_id_licencia);
    EXCEPTION WHEN OTHERS THEN
        -- Si no existe la función, continuar sin error
        NULL;
    END;

    -- Dar de baja la licencia
    UPDATE comun.licencias
    SET vigente = 'C',
        fecha_baja = CURRENT_DATE,
        axo_baja = p_anio,
        folio_baja = p_folio,
        espubic = p_motivo
    WHERE id_licencia = v_id_licencia;

    -- Registrar en bitácora si la tabla existe
    BEGIN
        INSERT INTO comun.lic_bajas_bitacora(
            id_licencia,
            licencia,
            usuario,
            fecha,
            motivo,
            anio,
            folio,
            baja_error,
            anuncios_dados_baja
        )
        VALUES (
            v_id_licencia,
            p_licencia,
            p_usuario,
            CURRENT_TIMESTAMP,
            p_motivo,
            p_anio,
            p_folio,
            p_baja_error,
            v_count_anuncios
        );
    EXCEPTION WHEN OTHERS THEN
        -- Si la tabla de bitácora no existe, continuar sin error
        NULL;
    END;

    -- Mensaje de éxito
    IF v_count_anuncios > 0 THEN
        RETURN QUERY SELECT TRUE,
            'Licencia #' || p_licencia || ' dada de baja correctamente. Se dieron de baja ' ||
            v_count_anuncios || ' anuncio(s) ligado(s).';
    ELSE
        RETURN QUERY SELECT TRUE, 'Licencia #' || p_licencia || ' dada de baja correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Mensajes de confirmación
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✓ comun.sp_bajalic_buscar_licencia creado correctamente';
    RAISE NOTICE '✓ comun.sp_bajalic_obtener_anuncios creado correctamente';
    RAISE NOTICE '✓ comun.sp_bajalic_ejecutar creado correctamente';
    RAISE NOTICE '✓ Instalación completada exitosamente';
END $$;
