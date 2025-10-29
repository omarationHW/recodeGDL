-- Stored Procedure: sp_get_requerimientos_by_multa
-- Tipo: Report
-- Descripción: Obtiene los requerimientos asociados a una multa
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

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