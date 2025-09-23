-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Responsivafrm
-- Generado: 2025-08-27 19:29:54
-- Total SPs: 6
-- ============================================

-- SP 1/6: buscar_licencia_responsiva
-- Tipo: Catalog
-- Descripción: Busca una licencia por número y retorna datos relevantes para la responsiva.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_licencia_responsiva(p_licencia INTEGER)
RETURNS TABLE (
    id_licencia INTEGER,
    licencia INTEGER,
    recaud INTEGER,
    descripcion TEXT,
    actividad TEXT,
    propietarionvo TEXT,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    colonia_ubic TEXT,
    cp TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.recaud, g.descripcion, l.actividad,
           trim(coalesce(l.primer_ap,'') || ' ' || coalesce(l.segundo_ap,'') || ' ' || coalesce(l.propietario,'')) as propietarionvo,
           l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.cp
    FROM licencias l
    LEFT JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: listar_responsivas
-- Tipo: Catalog
-- Descripción: Lista todas las responsivas o supervisiones según tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION listar_responsivas(p_tipo TEXT)
RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE r.tipo = p_tipo
    ORDER BY r.axo DESC, r.folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: crear_responsiva
-- Tipo: CRUD
-- Descripción: Crea una nueva responsiva o supervisión, asignando folio y año automáticamente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION crear_responsiva(
    p_id_licencia INTEGER,
    p_tipo TEXT, -- 'R' o 'S'
    p_usuario TEXT,
    p_observacion TEXT DEFAULT NULL
) RETURNS TABLE (axo INTEGER, folio INTEGER, id_licencia INTEGER, tipo TEXT, vigente TEXT, feccap DATE, capturista TEXT) AS $$
DECLARE
    v_folio INTEGER;
    v_axo INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_param_col TEXT;
BEGIN
    IF p_tipo = 'R' THEN
        v_param_col := 'responsiva';
    ELSE
        v_param_col := 'supervision';
    END IF;
    -- Obtener folio actual
    EXECUTE format('SELECT %I FROM parametros_lic', v_param_col) INTO v_folio;
    v_folio := v_folio + 1;
    -- Actualizar folio en parametros_lic
    EXECUTE format('UPDATE parametros_lic SET %I = $1', v_param_col) USING v_folio;
    -- Insertar responsiva
    INSERT INTO responsivas(axo, folio, id_licencia, tipo, observacion, vigente, feccap, capturista)
    VALUES (v_axo, v_folio, p_id_licencia, p_tipo, p_observacion, 'V', CURRENT_DATE, p_usuario);
    RETURN QUERY SELECT v_axo, v_folio, p_id_licencia, p_tipo, 'V', CURRENT_DATE, p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: cancelar_responsiva
-- Tipo: CRUD
-- Descripción: Cancela una responsiva/supervisión por axo y folio, guardando el motivo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION cancelar_responsiva(
    p_axo INTEGER,
    p_folio INTEGER,
    p_motivo TEXT,
    p_usuario TEXT
) RETURNS TABLE (axo INTEGER, folio INTEGER, vigente TEXT, observacion TEXT) AS $$
BEGIN
    UPDATE responsivas
    SET vigente = 'C', observacion = p_motivo, capturista = p_usuario
    WHERE axo = p_axo AND folio = p_folio;
    RETURN QUERY SELECT p_axo, p_folio, 'C', p_motivo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: buscar_responsiva_folio
-- Tipo: Catalog
-- Descripción: Busca responsiva por año y folio y tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_responsiva_folio(
    p_axo INTEGER,
    p_folio INTEGER,
    p_tipo TEXT
) RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE r.axo = p_axo AND r.folio = p_folio AND r.tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: buscar_responsiva_licencia
-- Tipo: Catalog
-- Descripción: Busca responsivas por número de licencia y tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_responsiva_licencia(
    p_licencia INTEGER,
    p_tipo TEXT
) RETURNS TABLE (
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    tipo TEXT,
    observacion TEXT,
    vigente TEXT,
    feccap DATE,
    capturista TEXT,
    licencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.axo, r.folio, r.id_licencia, r.tipo, r.observacion, r.vigente, r.feccap, r.capturista, l.licencia
    FROM responsivas r
    JOIN licencias l ON l.id_licencia = r.id_licencia
    WHERE l.licencia = p_licencia AND r.tipo = p_tipo
    ORDER BY r.axo DESC, r.folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

