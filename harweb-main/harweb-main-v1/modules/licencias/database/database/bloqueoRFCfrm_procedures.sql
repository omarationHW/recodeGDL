-- ============================================
-- STORED PROCEDURES PARA bloqueoRFCfrm
-- Generado: 2025-11-04
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_bloqueos_rfc_listar
-- Descripción: Lista todos los bloqueos de RFC
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_bloqueos_rfc_listar()
RETURNS TABLE(
    id INTEGER,
    rfc VARCHAR,
    id_tramite INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    actividad VARCHAR,
    fecha_hora TIMESTAMP,
    vigencia CHAR,
    capturista VARCHAR,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        br.id_bloqueo_rfc as id,
        br.rfc::VARCHAR,
        br.id_tramite::INTEGER,
        t.id_licencia::INTEGER as licencia,
        l.propietario::VARCHAR,
        l.actividad::VARCHAR as actividad,
        br.fecha_hora::TIMESTAMP,
        br.vigencia::CHAR,
        br.usuario::VARCHAR as capturista,
        br.observacion::TEXT
    FROM comun.ta_bloqueo_rfc br
    LEFT JOIN comun.tramites t ON br.id_tramite = t.id_tramite
    LEFT JOIN comun.licencias l ON t.id_licencia = l.id_licencia
    ORDER BY br.fecha_hora DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_bloqueos_rfc_buscar
-- Descripción: Busca bloqueos de RFC con filtros
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_bloqueos_rfc_buscar(
    p_rfc VARCHAR DEFAULT NULL,
    p_vigencia CHAR DEFAULT NULL
)
RETURNS TABLE(
    id INTEGER,
    rfc VARCHAR,
    id_tramite INTEGER,
    licencia INTEGER,
    propietario VARCHAR,
    actividad VARCHAR,
    fecha_hora TIMESTAMP,
    vigencia CHAR,
    capturista VARCHAR,
    observacion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        br.id_bloqueo_rfc as id,
        br.rfc::VARCHAR,
        br.id_tramite::INTEGER,
        t.id_licencia::INTEGER as licencia,
        l.propietario::VARCHAR,
        l.actividad::VARCHAR as actividad,
        br.fecha_hora::TIMESTAMP,
        br.vigencia::CHAR,
        br.usuario::VARCHAR as capturista,
        br.observacion::TEXT
    FROM comun.ta_bloqueo_rfc br
    LEFT JOIN comun.tramites t ON br.id_tramite = t.id_tramite
    LEFT JOIN comun.licencias l ON t.id_licencia = l.id_licencia
    WHERE (p_rfc IS NULL OR br.rfc ILIKE '%' || p_rfc || '%')
      AND (p_vigencia IS NULL OR br.vigencia = p_vigencia)
    ORDER BY br.fecha_hora DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_tramite_buscar_para_rfc
-- Descripción: Busca información de un trámite para bloqueo de RFC
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_tramite_buscar_para_rfc(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    rfc VARCHAR,
    id_licencia INTEGER,
    propietario VARCHAR,
    actividad VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite::INTEGER,
        t.rfc::VARCHAR,
        t.id_licencia::INTEGER,
        l.propietario::VARCHAR,
        l.actividad::VARCHAR as actividad
    FROM comun.tramites t
    LEFT JOIN comun.licencias l ON t.id_licencia = l.id_licencia
    WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_bloqueo_rfc_crear
-- Descripción: Crea un nuevo bloqueo de RFC
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_crear(
    p_id_tramite INTEGER,
    p_rfc VARCHAR,
    p_observacion VARCHAR,
    p_usuario VARCHAR DEFAULT 'admin'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    -- Verificar si ya existe un bloqueo vigente para este RFC y trámite
    SELECT EXISTS(
        SELECT 1 FROM comun.ta_bloqueo_rfc
        WHERE id_tramite = p_id_tramite
          AND rfc = p_rfc
          AND vigencia = 'V'
    ) INTO v_existe;

    IF v_existe THEN
        RETURN QUERY SELECT false, 'Ya existe un bloqueo vigente para este RFC y trámite'::VARCHAR;
        RETURN;
    END IF;

    -- Insertar el bloqueo
    INSERT INTO comun.ta_bloqueo_rfc (
        id_tramite,
        rfc,
        fecha_hora,
        vigencia,
        usuario,
        observacion
    ) VALUES (
        p_id_tramite,
        p_rfc,
        CURRENT_TIMESTAMP,
        'V',
        p_usuario,
        p_observacion
    );

    RETURN QUERY SELECT true, 'Bloqueo de RFC creado exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error al crear bloqueo: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_bloqueo_rfc_actualizar
-- Descripción: Actualiza un bloqueo de RFC existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_actualizar(
    p_id INTEGER,
    p_id_tramite INTEGER,
    p_rfc VARCHAR,
    p_observacion VARCHAR,
    p_usuario VARCHAR DEFAULT 'admin'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Actualizar el bloqueo
    UPDATE comun.ta_bloqueo_rfc
    SET observacion = p_observacion,
        usuario = p_usuario
    WHERE id_bloqueo_rfc = p_id
      AND vigencia = 'V';

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Bloqueo de RFC actualizado exitosamente'::VARCHAR;
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el bloqueo o ya no está vigente'::VARCHAR;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error al actualizar bloqueo: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_bloqueo_rfc_desbloquear
-- Descripción: Desbloquea un RFC (cancela el bloqueo)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_bloqueo_rfc_desbloquear(
    p_id INTEGER,
    p_usuario VARCHAR DEFAULT 'admin'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Cambiar la vigencia a 'C' (Cancelado)
    UPDATE comun.ta_bloqueo_rfc
    SET vigencia = 'C',
        usuario = p_usuario,
        fecha_hora = CURRENT_TIMESTAMP
    WHERE id_bloqueo_rfc = p_id
      AND vigencia = 'V';

    IF FOUND THEN
        RETURN QUERY SELECT true, 'RFC desbloqueado exitosamente'::VARCHAR;
    ELSE
        RETURN QUERY SELECT false, 'No se encontró el bloqueo o ya está cancelado'::VARCHAR;
    END IF;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error al desbloquear RFC: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- NOTAS:
-- 1. La tabla ta_bloqueo_rfc debe existir en el esquema comun
-- 2. Campos de ta_bloqueo_rfc: id_bloqueo_rfc (PK), id_tramite, rfc, fecha_hora, vigencia, usuario, observacion
-- 3. Relación con tramites: id_tramite -> tramites.id_tramite
-- 4. Relación con licencias: tramites.id_licencia -> licencias.id_licencia
-- 5. vigencia: 'V' = Vigente, 'C' = Cancelado
