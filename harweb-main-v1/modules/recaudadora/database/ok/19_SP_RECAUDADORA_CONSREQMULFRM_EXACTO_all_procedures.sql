-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consreqmulfrm (Consulta Requerimientos Multas)
-- Generado: 2025-08-26 23:43:36
-- Total SPs: 7
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
    RETURN QUERY 
    SELECT 
        m.id_multa, m.id_dependencia, m.axo_acta, m.num_acta, m.contribuyente, 
        m.domicilio, m.calificacion, m.multa, m.fecha_cancelacion, m.cvepago, m.comentario
    FROM public.multas m
    WHERE m.id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_search_multas
-- Tipo: Report
-- Descripción: Busca multas por contribuyente, domicilio o dependencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_search_multas(
    p_contribuyente TEXT DEFAULT NULL,
    p_domicilio TEXT DEFAULT NULL,
    p_id_dependencia INTEGER DEFAULT NULL
) RETURNS TABLE (
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
    RETURN QUERY 
    SELECT 
        m.id_multa, m.id_dependencia, m.axo_acta, m.num_acta, m.contribuyente, 
        m.domicilio, m.calificacion, m.multa, m.fecha_cancelacion, m.cvepago, m.comentario
    FROM public.multas m
    WHERE (p_contribuyente IS NULL OR m.contribuyente ILIKE '%' || p_contribuyente || '%')
      AND (p_domicilio IS NULL OR m.domicilio ILIKE '%' || p_domicilio || '%')
      AND (p_id_dependencia IS NULL OR m.id_dependencia = p_id_dependencia)
    ORDER BY m.axo_acta, m.num_acta;
END;
$$ LANGUAGE plpgsql;

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
    RETURN QUERY 
    SELECT 
        r.axoreq, r.folioreq, r.tipo, r.fecemi, r.fecpract, r.multas, 
        r.gasto_req, r.gastos, r.total, r.vigencia
    FROM public.reqmultas r
    WHERE r.id_multa = p_id_multa 
    ORDER BY r.axoreq, r.folioreq;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_update_multa
-- Tipo: CRUD
-- Descripción: Actualiza los datos de una multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_multa(
    p_id_multa INTEGER,
    p_calificacion NUMERIC,
    p_multa NUMERIC,
    p_comentario TEXT,
    p_user TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE public.multas 
    SET calificacion = p_calificacion, 
        multa = p_multa, 
        comentario = p_comentario, 
        capturista = p_user, 
        updated_at = NOW()
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

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
    UPDATE public.multas 
    SET fecha_cancelacion = NOW(), 
        user_baja = p_user, 
        comentario = p_observacion 
    WHERE id_multa = p_id_multa;
    
    UPDATE public.reqmultas 
    SET vigencia = 'C' 
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_get_prescripcion
-- Tipo: Report
-- Descripción: Obtiene la prescripción por id_prescri
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_prescripcion(p_id_prescri INTEGER)
RETURNS TABLE (
    id_prescri INTEGER,
    id_multa INTEGER,
    fecaut DATE,
    fecha_prescri DATE,
    oficio TEXT,
    capturista TEXT,
    dependencia TEXT,
    observaciones TEXT
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        p.id_prescri, p.id_multa, p.fecaut, p.fecha_prescri, p.oficio, 
        p.capturista, p.dependencia, p.observaciones
    FROM public.presc_multas p
    WHERE p.id_prescri = p_id_prescri;
END;
$$ LANGUAGE plpgsql;

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
    RETURN QUERY 
    SELECT 
        h.id_multa, h.id_dependencia, h.axo_acta, h.num_acta, h.fecha_acta,
        h.contribuyente, h.domicilio, h.calificacion, h.multa, h.fecha_cancelacion, h.comentario
    FROM public.h_multasnvo h
    WHERE h.id_dependencia = p_id_dependencia 
      AND h.axo_acta = p_axo_acta 
      AND h.num_acta = p_num_acta;
END;
$$ LANGUAGE plpgsql;

-- ============================================