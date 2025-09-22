-- ============================================
-- STORED PROCEDURES PARA DICTAMENUSODESUELO
-- Base de datos: padron_licencias
-- Siguiendo patrón de consultapredial.vue
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- SP_DICTAMENUSO_LIST: Lista dictámenes de uso de suelo con filtros y paginación
-- Mejora del dictamenusodesuelo_list existente
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_LIST(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_solicita VARCHAR DEFAULT NULL,
    p_licencia INTEGER DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL,
    p_fecha_ini DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id varchar,
    axo integer,
    folio integer,
    licencia integer,
    solicita varchar,
    partidapago varchar,
    observacion varchar,
    domicilio varchar,
    vigente varchar,
    vigente_texto varchar,
    feccap date,
    capturista varchar,
    tipo integer,
    tipo_texto varchar,
    id_licencia integer,
    total_registros bigint
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (c.axo || '-' || c.folio)::varchar as id,
        c.axo,
        c.folio,
        c.licencia,
        c.solicita,
        c.partidapago,
        c.observacion,
        c.domicilio,
        c.vigente,
        CASE
            WHEN c.vigente = 'V' THEN 'Vigente'
            WHEN c.vigente = 'C' THEN 'Cancelado'
            ELSE 'Desconocido'
        END as vigente_texto,
        c.feccap,
        c.capturista,
        c.tipo,
        CASE
            WHEN c.tipo = 0 THEN 'Licencia'
            WHEN c.tipo = 1 THEN 'No Licencia'
            WHEN c.tipo = 2 THEN 'No Licencia Propietario'
            WHEN c.tipo = 3 THEN 'No Licencia Vigente'
            ELSE 'Otro'
        END as tipo_texto,
        c.id_licencia,
        COUNT(*) OVER() as total_registros
    FROM constancias c
    WHERE (p_axo IS NULL OR c.axo = p_axo)
      AND (p_folio IS NULL OR c.folio = p_folio)
      AND (p_solicita IS NULL OR UPPER(c.solicita) LIKE UPPER('%' || p_solicita || '%'))
      AND (p_licencia IS NULL OR c.licencia = p_licencia)
      AND (p_vigente IS NULL OR c.vigente = p_vigente)
      AND (p_fecha_ini IS NULL OR c.feccap >= p_fecha_ini)
      AND (p_fecha_fin IS NULL OR c.feccap <= p_fecha_fin)
    ORDER BY c.axo DESC, c.folio DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMENUSO_CREATE: Crear nuevo dictamen de uso de suelo
-- Mejora del dictamenusodesuelo_create existente
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_CREATE(
    p_solicita VARCHAR,
    p_partidapago VARCHAR DEFAULT NULL,
    p_observacion VARCHAR DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_licencia INTEGER DEFAULT NULL,
    p_capturista VARCHAR DEFAULT 'SISTEMA',
    p_tipo INTEGER DEFAULT 0
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    axo INTEGER,
    folio INTEGER,
    id_generado VARCHAR
) AS $$
DECLARE
    v_folio INTEGER;
    v_axo INTEGER;
    v_id VARCHAR;
BEGIN
    -- Validaciones básicas
    IF p_solicita IS NULL OR TRIM(p_solicita) = '' THEN
        RETURN QUERY SELECT FALSE, 'El campo "Solicita" es requerido'::VARCHAR, NULL::INTEGER, NULL::INTEGER, NULL::VARCHAR;
        RETURN;
    END IF;

    -- Obtener año actual
    v_axo := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;

    -- Obtener siguiente folio de parámetros
    SELECT constancia + 1 INTO v_folio FROM parametros LIMIT 1;

    -- Si no existe registro en parámetros, empezar desde 1
    IF v_folio IS NULL THEN
        INSERT INTO parametros (constancia) VALUES (1);
        v_folio := 1;
    END IF;

    -- Actualizar contador en parámetros
    UPDATE parametros SET constancia = v_folio;

    -- Crear ID compuesto
    v_id := v_axo || '-' || v_folio;

    -- Insertar nueva constancia
    INSERT INTO constancias (
        axo, folio, id_licencia, licencia, solicita, partidapago,
        observacion, domicilio, vigente, feccap, capturista, tipo
    ) VALUES (
        v_axo, v_folio, p_id_licencia, p_licencia, p_solicita,
        p_partidapago, p_observacion, p_domicilio, 'V',
        CURRENT_DATE, p_capturista, p_tipo
    );

    RETURN QUERY SELECT TRUE, 'Dictamen de uso de suelo creado exitosamente'::VARCHAR, v_axo, v_folio, v_id;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error al crear dictamen: ' || SQLERRM)::VARCHAR, NULL::INTEGER, NULL::INTEGER, NULL::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMENUSO_UPDATE: Actualizar dictamen de uso de suelo existente
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_UPDATE(
    p_axo INTEGER,
    p_folio INTEGER,
    p_solicita VARCHAR DEFAULT NULL,
    p_partidapago VARCHAR DEFAULT NULL,
    p_observacion VARCHAR DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_tipo INTEGER DEFAULT NULL,
    p_capturista VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Verificar si existe la constancia
    IF NOT EXISTS (SELECT 1 FROM constancias WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'El dictamen no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si está vigente
    IF EXISTS (SELECT 1 FROM constancias WHERE axo = p_axo AND folio = p_folio AND vigente = 'C') THEN
        RETURN QUERY SELECT FALSE, 'No se puede actualizar un dictamen cancelado'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar constancia
    UPDATE constancias SET
        solicita = COALESCE(p_solicita, solicita),
        partidapago = COALESCE(p_partidapago, partidapago),
        observacion = COALESCE(p_observacion, observacion),
        domicilio = COALESCE(p_domicilio, domicilio),
        tipo = COALESCE(p_tipo, tipo),
        capturista = COALESCE(p_capturista, capturista)
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Dictamen actualizado exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error al actualizar dictamen: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMENUSO_DETAILS: Obtener detalles completos del dictamen
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_DETAILS(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    axo integer,
    folio integer,
    id_generado varchar,
    licencia integer,
    solicita varchar,
    partidapago varchar,
    observacion varchar,
    domicilio varchar,
    vigente varchar,
    vigente_texto varchar,
    feccap date,
    capturista varchar,
    tipo integer,
    tipo_texto varchar,
    id_licencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        (c.axo || '-' || c.folio)::varchar as id_generado,
        c.licencia,
        c.solicita,
        c.partidapago,
        c.observacion,
        c.domicilio,
        c.vigente,
        CASE
            WHEN c.vigente = 'V' THEN 'Vigente'
            WHEN c.vigente = 'C' THEN 'Cancelado'
            ELSE 'Desconocido'
        END as vigente_texto,
        c.feccap,
        c.capturista,
        c.tipo,
        CASE
            WHEN c.tipo = 0 THEN 'Licencia'
            WHEN c.tipo = 1 THEN 'No Licencia'
            WHEN c.tipo = 2 THEN 'No Licencia Propietario'
            WHEN c.tipo = 3 THEN 'No Licencia Vigente'
            ELSE 'Otro'
        END as tipo_texto,
        c.id_licencia
    FROM constancias c
    WHERE c.axo = p_axo AND c.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMENUSO_CANCEL: Cancelar dictamen (mejora del existente)
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_CANCEL(
    p_axo INTEGER,
    p_folio INTEGER,
    p_motivo VARCHAR DEFAULT 'Cancelado por usuario'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Verificar si existe la constancia
    IF NOT EXISTS (SELECT 1 FROM constancias WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'El dictamen no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si ya está cancelado
    IF EXISTS (SELECT 1 FROM constancias WHERE axo = p_axo AND folio = p_folio AND vigente = 'C') THEN
        RETURN QUERY SELECT FALSE, 'El dictamen ya está cancelado'::VARCHAR;
        RETURN;
    END IF;

    -- Cancelar constancia
    UPDATE constancias SET
        vigente = 'C',
        observacion = COALESCE(p_motivo, 'Cancelado por usuario')
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Dictamen cancelado exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error al cancelar dictamen: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- SP_DICTAMENUSO_REACTIVAR: Reactivar dictamen cancelado
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_REACTIVAR(
    p_axo INTEGER,
    p_folio INTEGER,
    p_motivo VARCHAR DEFAULT 'Reactivado por usuario'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR
) AS $$
BEGIN
    -- Verificar si existe la constancia
    IF NOT EXISTS (SELECT 1 FROM constancias WHERE axo = p_axo AND folio = p_folio) THEN
        RETURN QUERY SELECT FALSE, 'El dictamen no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar si está cancelado
    IF NOT EXISTS (SELECT 1 FROM constancias WHERE axo = p_axo AND folio = p_folio AND vigente = 'C') THEN
        RETURN QUERY SELECT FALSE, 'El dictamen no está cancelado'::VARCHAR;
        RETURN;
    END IF;

    -- Reactivar constancia
    UPDATE constancias SET
        vigente = 'V',
        observacion = COALESCE(p_motivo, 'Reactivado por usuario')
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT TRUE, 'Dictamen reactivado exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, ('Error al reactivar dictamen: ' || SQLERRM)::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- Crear índices para optimizar rendimiento
CREATE INDEX IF NOT EXISTS idx_constancias_axo_folio ON constancias(axo, folio);
CREATE INDEX IF NOT EXISTS idx_constancias_vigente ON constancias(vigente);
CREATE INDEX IF NOT EXISTS idx_constancias_solicita ON constancias(solicita);
CREATE INDEX IF NOT EXISTS idx_constancias_feccap ON constancias(feccap);
CREATE INDEX IF NOT EXISTS idx_constancias_tipo ON constancias(tipo);

-- ============================================
-- FIN DE STORED PROCEDURES PARA DICTAMENUSO
-- ============================================