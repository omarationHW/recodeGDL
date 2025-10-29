-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_calificacionQR
-- Generado: 2025-08-27 15:42:11
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_calificacion_qr
-- Tipo: Report
-- Descripción: Obtiene los datos principales de la multa para impresión QR
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_calificacion_qr(p_id_multa integer)
RETURNS TABLE (
    id_multa integer,
    id_dependencia smallint,
    axo_acta smallint,
    num_acta integer,
    fecha_acta date,
    fecha_cancelacion date,
    contribuyente varchar,
    domicilio varchar,
    recaud smallint,
    num_licencia integer,
    giro varchar,
    calificacion numeric,
    multa numeric,
    gastos numeric,
    total numeric,
    cvepago integer,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_multa, id_dependencia, axo_acta, num_acta, fecha_acta, fecha_cancelacion, contribuyente, domicilio, recaud, num_licencia, giro, calificacion, multa, gastos, total, cvepago, capturista
    FROM multas
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_multas_articulos
-- Tipo: Report
-- Descripción: Obtiene los artículos relacionados a una multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_multas_articulos(p_id_multa integer)
RETURNS TABLE (
    id_ley smallint,
    art_reg varchar,
    fracc_reg varchar,
    num_reg varchar,
    inciso_reg varchar,
    art_ley varchar,
    fracc_ley varchar,
    num_ley varchar,
    inciso_ley varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_ley, art_reg, fracc_reg, num_reg, inciso_reg, art_ley, fracc_ley, num_ley, inciso_ley
    FROM multas_articulos
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

