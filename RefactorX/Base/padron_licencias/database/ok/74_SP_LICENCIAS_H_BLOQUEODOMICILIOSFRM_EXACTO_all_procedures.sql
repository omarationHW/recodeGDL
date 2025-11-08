-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: H_BLOQUEODOMICILIOSFRM (EXACTO del archivo original)
-- Archivo: 74_SP_LICENCIAS_H_BLOQUEODOMICILIOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_h_bloqueo_dom_listar
-- Tipo: Report
-- Descripción: Lista todos los domicilios históricos bloqueados, ordenados por el campo especificado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_listar(p_order TEXT DEFAULT 'calle,num_ext')
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
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT * FROM h_bloqueo_dom ORDER BY %s', p_order);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: H_BLOQUEODOMICILIOSFRM (EXACTO del archivo original)
-- Archivo: 74_SP_LICENCIAS_H_BLOQUEODOMICILIOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_h_bloqueo_dom_detalle
-- Tipo: Catalog
-- Descripción: Obtiene el detalle de un domicilio histórico bloqueado por ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_h_bloqueo_dom_detalle(p_id INTEGER)
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
    hora TIMESTAMP,
    vig VARCHAR,
    observacion VARCHAR,
    capturista VARCHAR,
    fecha_mov TIMESTAMP,
    motivo_mov VARCHAR,
    tipo_mov VARCHAR,
    modifico VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM h_bloqueo_dom WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

