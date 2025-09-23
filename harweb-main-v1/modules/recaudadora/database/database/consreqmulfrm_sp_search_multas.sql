-- Stored Procedure: sp_search_multas
-- Tipo: Report
-- Descripción: Busca multas por contribuyente, domicilio o dependencia
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

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
    RETURN QUERY SELECT id_multa, id_dependencia, axo_acta, num_acta, contribuyente, domicilio, calificacion, multa, fecha_cancelacion, cvepago, comentario
    FROM multas
    WHERE (p_contribuyente IS NULL OR contribuyente ILIKE '%' || p_contribuyente || '%')
      AND (p_domicilio IS NULL OR domicilio ILIKE '%' || p_domicilio || '%')
      AND (p_id_dependencia IS NULL OR id_dependencia = p_id_dependencia)
    ORDER BY axo_acta, num_acta;
END;
$$ LANGUAGE plpgsql;