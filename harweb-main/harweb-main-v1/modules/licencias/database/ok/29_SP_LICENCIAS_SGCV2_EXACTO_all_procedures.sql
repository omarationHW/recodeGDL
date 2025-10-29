-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SGCV2 (EXACTO del archivo original)
-- Archivo: 29_SP_LICENCIAS_SGCV2_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SGCV2 (EXACTO del archivo original)
-- Archivo: 29_SP_LICENCIAS_SGCV2_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
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
        SELECT * FROM public WHERE licencia = p_licencia
    ) t;
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SGCV2 (EXACTO del archivo original)
-- Archivo: 29_SP_LICENCIAS_SGCV2_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SGCV2 (EXACTO del archivo original)
-- Archivo: 29_SP_LICENCIAS_SGCV2_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
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
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW() WHERE id_licencia = (SELECT id_licencia FROM public WHERE licencia = p_licencia);
    v_result := json_build_object('licencia', p_licencia, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SGCV2 (EXACTO del archivo original)
-- Archivo: 29_SP_LICENCIAS_SGCV2_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
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

