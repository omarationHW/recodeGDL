-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SGCv2
-- Generado: 2025-08-27 19:38:17
-- Total SPs: 9
-- ============================================

-- SP 1/9: sp_buscar_cuenta_catastral
-- Tipo: Catalog
-- Descripción: Busca cuenta catastral por recaudadora, urbrus y cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_cuenta_catastral(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    claveutm VARCHAR,
    manzana VARCHAR,
    ctacat VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, recaud, urbrus, cuenta, cvecatnva, subpredio,
           (recaud || '-' || urbrus || '-' || cuenta) AS claveutm,
           (cip || subpredio) AS manzana,
           (cvecatnva || subpredio) AS ctacat,
           vigente
    FROM convcta
    WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/9: sp_alta_tramite_licencia
-- Tipo: CRUD
-- Descripción: Alta de trámite de licencia, recibe JSON con todos los datos y realiza inserción y lógica de negocio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_tramite_licencia(p_json JSON)
RETURNS JSON AS $$
DECLARE
    v_id_tramite INTEGER;
    v_result JSON;
BEGIN
    -- Extraer campos del JSON y realizar inserciones en tramites, licencias, etc.
    -- Ejemplo (simplificado):
    INSERT INTO tramites (tipo_tramite, id_giro, propietario, rfc, curp, domicilio, telefono_prop, email, feccap)
    VALUES (
        (p_json->>'tipo_tramite')::INTEGER,
        (p_json->>'id_giro')::INTEGER,
        p_json->>'propietario',
        p_json->>'rfc',
        p_json->>'curp',
        p_json->>'domicilio',
        p_json->>'telefono_prop',
        p_json->>'email',
        NOW()
    ) RETURNING id_tramite INTO v_id_tramite;
    -- ... lógica adicional ...
    v_result := json_build_object('id_tramite', v_id_tramite, 'status', 'ok');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/9: sp_consulta_licencia
-- Tipo: Catalog
-- Descripción: Consulta de licencia por número
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_licencia(p_licencia INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM licencias WHERE licencia = p_licencia
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/9: sp_consulta_anuncio
-- Tipo: Catalog
-- Descripción: Consulta de anuncio por número
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_anuncio(p_anuncio INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM anuncios WHERE anuncio = p_anuncio
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/9: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia por motivo y usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET bloqueado = 1 WHERE licencia = p_licencia;
    INSERT INTO bloqueo (id_licencia, bloqueado, observacion, capturista, fecha_mov, vigente)
    VALUES (p_licencia, 1, p_motivo, p_usuario, NOW(), 'V');
    v_result := json_build_object('licencia', p_licencia, 'status', 'bloqueada');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/9: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia por motivo y usuario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET bloqueado = 0 WHERE licencia = p_licencia;
    INSERT INTO bloqueo (id_licencia, bloqueado, observacion, capturista, fecha_mov, vigente)
    VALUES (p_licencia, 0, p_motivo, p_usuario, NOW(), 'V');
    v_result := json_build_object('licencia', p_licencia, 'status', 'desbloqueada');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/9: sp_baja_licencia
-- Tipo: CRUD
-- Descripción: Da de baja una licencia y sus anuncios ligados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET vigente = 'C', fecha_baja = NOW(), espubic = p_motivo WHERE licencia = p_licencia;
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW() WHERE id_licencia = (SELECT id_licencia FROM licencias WHERE licencia = p_licencia);
    v_result := json_build_object('licencia', p_licencia, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/9: sp_baja_anuncio
-- Tipo: CRUD
-- Descripción: Da de baja un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_anuncio(p_anuncio INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW(), espubic = p_motivo WHERE anuncio = p_anuncio;
    v_result := json_build_object('anuncio', p_anuncio, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/9: sp_consulta_tramite
-- Tipo: Catalog
-- Descripción: Consulta de trámite por número
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_tramite(p_tramite INTEGER)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT row_to_json(t) INTO v_result
    FROM (
        SELECT * FROM tramites WHERE id_tramite = p_tramite
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

