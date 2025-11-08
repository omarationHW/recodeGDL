-- ============================================
-- STORED PROCEDURES PARA BLOQUEO DE RFC
-- Componente: bloqueoRFCfrm.vue
-- Fecha: 2025-11-06
-- Descripción: Gestión de bloqueos por RFC de Licencias
-- ============================================

-- NOTA: Requiere tabla bloqueo_rfc_lic con estructura:
-- CREATE TABLE IF NOT EXISTS comun.bloqueo_rfc_lic (
--     rfc VARCHAR(13),
--     id_tramite INTEGER,
--     licencia INTEGER,
--     hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     vig CHAR(1) DEFAULT 'V',
--     observacion VARCHAR(255),
--     capturista VARCHAR(10)
-- );

-- ============================================
-- SP 1/4: sp_bloqueorfc_list
-- Descripción: Lista bloqueos de RFC con filtros y paginación
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 10,
    p_rfc VARCHAR DEFAULT NULL,
    p_tipo_bloqueo VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    rfc VARCHAR,
    id_tramite INTEGER,
    licencia INTEGER,
    hora TIMESTAMP,
    vig CHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    propietario_completo VARCHAR,
    actividad VARCHAR,
    total_count BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    RETURN QUERY
    WITH bloqueos_filtrados AS (
        SELECT DISTINCT ON (b.rfc, b.hora)
            b.rfc::VARCHAR,
            b.id_tramite::INTEGER,
            b.licencia::INTEGER,
            b.hora::TIMESTAMP,
            b.vig::CHAR,
            b.observacion::VARCHAR,
            b.capturista::VARCHAR,
            TRIM(TRIM(COALESCE(tr.primer_ap, '')) || ' ' ||
                 TRIM(COALESCE(tr.segundo_ap, '')) || ' ' ||
                 TRIM(COALESCE(tr.propietario, '')))::VARCHAR as propietario_completo,
            TRIM(COALESCE(tr.actividad, ''))::VARCHAR as actividad
        FROM comun.bloqueo_rfc_lic b
        LEFT JOIN comun.tramites tr ON tr.id_tramite = b.id_tramite
        WHERE (p_rfc IS NULL OR p_rfc = '' OR b.rfc ILIKE '%' || p_rfc || '%')
            AND (p_tipo_bloqueo IS NULL OR p_tipo_bloqueo = '' OR
                (p_tipo_bloqueo = 'vigente' AND b.vig = 'V') OR
                (p_tipo_bloqueo = 'cancelado' AND b.vig = 'C'))
        ORDER BY b.rfc, b.hora, b.id_tramite
    ),
    total AS (
        SELECT COUNT(*) as cnt FROM bloqueos_filtrados
    )
    SELECT
        bf.rfc,
        bf.id_tramite,
        bf.licencia,
        bf.hora,
        bf.vig,
        bf.observacion,
        bf.capturista,
        bf.propietario_completo,
        bf.actividad,
        t.cnt as total_count
    FROM bloqueos_filtrados bf
    CROSS JOIN total t
    ORDER BY bf.hora DESC
    LIMIT p_page_size
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/4: sp_bloqueorfc_buscar_tramite
-- Descripción: Busca información de un trámite por folio
-- Consulta la tabla comun.tramites
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_buscar_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR,
    id_tramite INTEGER,
    id_licencia INTEGER,
    rfc VARCHAR,
    actividad VARCHAR,
    propietario VARCHAR
) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Verificar si el trámite existe
    SELECT COUNT(*) INTO v_count
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF v_count = 0 THEN
        RETURN QUERY SELECT
            FALSE,
            'No se encontró el trámite con ID: ' || p_id_tramite::VARCHAR,
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::VARCHAR,
            NULL::VARCHAR,
            NULL::VARCHAR;
        RETURN;
    END IF;

    -- Retornar datos del trámite
    RETURN QUERY
    SELECT
        TRUE,
        'Trámite encontrado exitosamente'::VARCHAR,
        t.id_tramite::INTEGER,
        t.id_licencia::INTEGER,
        TRIM(COALESCE(t.rfc, ''))::VARCHAR as rfc,
        TRIM(COALESCE(t.actividad, ''))::VARCHAR as actividad,
        TRIM(TRIM(COALESCE(t.primer_ap, '')) || ' ' ||
             TRIM(COALESCE(t.segundo_ap, '')) || ' ' ||
             TRIM(COALESCE(t.propietario, '')))::VARCHAR as propietario
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 3/4: sp_bloqueorfc_create
-- Descripción: Crea un nuevo bloqueo de RFC
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_create(
    p_rfc VARCHAR,
    p_id_tramite INTEGER,
    p_licencia INTEGER,
    p_observacion VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Validar que no exista un bloqueo vigente para este RFC
    SELECT COUNT(*) INTO v_exists
    FROM comun.bloqueo_rfc_lic
    WHERE rfc = p_rfc AND vig = 'V';

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe un bloqueo vigente para este RFC'::VARCHAR;
        RETURN;
    END IF;

    -- Insertar el nuevo bloqueo
    INSERT INTO comun.bloqueo_rfc_lic (
        rfc,
        id_tramite,
        licencia,
        hora,
        vig,
        observacion,
        capturista
    )
    VALUES (
        p_rfc,
        p_id_tramite,
        p_licencia,
        CURRENT_TIMESTAMP,
        'V',
        p_observacion,
        p_usuario
    );

    RETURN QUERY SELECT TRUE, 'Bloqueo de RFC registrado exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 4/4: sp_bloqueorfc_desbloquear
-- Descripción: Desbloquea un RFC (cambia vigencia a 'C')
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_bloqueorfc_desbloquear(
    p_rfc VARCHAR,
    p_motivo VARCHAR,
    p_usuario VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
    v_updated INTEGER;
BEGIN
    -- Verificar que exista un bloqueo vigente
    SELECT COUNT(*) INTO v_exists
    FROM comun.bloqueo_rfc_lic
    WHERE rfc = p_rfc AND vig = 'V';

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe un bloqueo vigente para este RFC'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar el bloqueo
    UPDATE comun.bloqueo_rfc_lic
    SET observacion = COALESCE(observacion || ' | ', '') || 'DESBLOQUEADO: ' || p_motivo,
        vig = 'C',
        hora = CURRENT_TIMESTAMP,
        capturista = p_usuario
    WHERE rfc = p_rfc AND vig = 'V';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        RETURN QUERY SELECT TRUE, 'RFC desbloqueado exitosamente'::VARCHAR;
    ELSE
        RETURN QUERY SELECT FALSE, 'Error al desbloquear el RFC'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FIN DE STORED PROCEDURES
-- ============================================
