-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEODOMICILIOSFRM (EXACTO del archivo original)
-- Archivo: 40_SP_LICENCIAS_BLOQUEODOMICILIOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_bloqueo_dom_add
-- Tipo: CRUD
-- Descripción: Agrega un domicilio bloqueado y regresa el folio generado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_dom_add(
    p_cvecalle INTEGER,
    p_calle VARCHAR,
    p_num_ext INTEGER,
    p_let_ext VARCHAR,
    p_num_int INTEGER,
    p_let_int VARCHAR,
    p_observacion VARCHAR,
    p_capturista VARCHAR,
    p_fecha DATE
) RETURNS INTEGER AS $$
DECLARE
    v_folio INTEGER;
BEGIN
    INSERT INTO bloqueo_dom (cvecalle, calle, num_ext, let_ext, num_int, let_int, observacion, capturista, fecha, hora, vig)
    VALUES (p_cvecalle, p_calle, p_num_ext, p_let_ext, p_num_int, p_let_int, p_observacion, p_capturista, p_fecha, NOW(), 'V')
    RETURNING folio INTO v_folio;
    RETURN v_folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: BLOQUEODOMICILIOSFRM (EXACTO del archivo original)
-- Archivo: 40_SP_LICENCIAS_BLOQUEODOMICILIOSFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_bloqueo_dom_delete
-- Tipo: CRUD
-- Descripción: Elimina (cancela) un domicilio bloqueado y guarda histórico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_dom_delete(
    p_folio INTEGER,
    p_motivo VARCHAR,
    p_usuario VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM bloqueo_dom WHERE folio = p_folio;
    IF v_row IS NULL THEN
        RETURN FALSE;
    END IF;
    -- Guarda histórico
    INSERT INTO h_bloqueo_dom SELECT *, NOW(), p_motivo, 'ED', p_usuario FROM bloqueo_dom WHERE folio = p_folio;
    DELETE FROM bloqueo_dom WHERE folio = p_folio;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

