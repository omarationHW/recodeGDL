-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSREQMULFRM (EXACTO del archivo original)
-- Archivo: 88_SP_RECAUDADORA_CONSREQMULFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_get_multas_by_id
-- Tipo: CRUD
-- Descripción: Obtiene una multa por su ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_multas_by_id(p_id_multa INTEGER)
RETURNS TABLE (
    id_multa INTEGER,
    id_dependencia INTEGER,
    axo_acta INTEGER,
    num_acta INTEGER,
    contribuyente TEXT,
    domicilio TEXT,
    calificacion NUMERIC,
    multa NUMERIC,
    fecha_cancelacion DATE,
    cvepago INTEGER,
    comentario TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id_multa, id_dependencia, axo_acta, num_acta, contribuyente, domicilio, calificacion, multa, fecha_cancelacion, cvepago, comentario
    FROM multas WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSREQMULFRM (EXACTO del archivo original)
-- Archivo: 88_SP_RECAUDADORA_CONSREQMULFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_get_requerimientos_by_multa
-- Tipo: Report
-- Descripción: Obtiene los requerimientos asociados a una multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos_by_multa(p_id_multa INTEGER)
RETURNS TABLE (
    axoreq INTEGER,
    folioreq INTEGER,
    tipo TEXT,
    fecemi DATE,
    fecpract DATE,
    multas NUMERIC,
    gasto_req NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    vigencia TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT axoreq, folioreq, tipo, fecemi, fecpract, multas, gasto_req, gastos, total, vigencia
    FROM reqmultas WHERE id_multa = p_id_multa ORDER BY axoreq, folioreq;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSREQMULFRM (EXACTO del archivo original)
-- Archivo: 88_SP_RECAUDADORA_CONSREQMULFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_cancel_multa
-- Tipo: CRUD
-- Descripción: Cancela una multa y todos sus requerimientos asociados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancel_multa(
    p_id_multa INTEGER,
    p_user TEXT,
    p_observacion TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE multas SET fecha_cancelacion = NOW(), user_baja = p_user, comentario = p_observacion WHERE id_multa = p_id_multa;
    UPDATE reqmultas SET vigencia = 'C' WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSREQMULFRM (EXACTO del archivo original)
-- Archivo: 88_SP_RECAUDADORA_CONSREQMULFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_get_multas_historico
-- Tipo: Report
-- Descripción: Obtiene el histórico de una multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_multas_historico(
    p_id_dependencia INTEGER,
    p_axo_acta INTEGER,
    p_num_acta INTEGER
) RETURNS TABLE (
    id_multa INTEGER,
    id_dependencia INTEGER,
    axo_acta INTEGER,
    num_acta INTEGER,
    fecha_acta DATE,
    contribuyente TEXT,
    domicilio TEXT,
    calificacion NUMERIC,
    multa NUMERIC,
    fecha_cancelacion DATE,
    comentario TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id_multa, id_dependencia, axo_acta, num_acta, fecha_acta, contribuyente, domicilio, calificacion, multa, fecha_cancelacion, comentario
    FROM h_multasnvo WHERE id_dependencia = p_id_dependencia AND axo_acta = p_axo_acta AND num_acta = p_num_acta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

