-- Stored Procedure: sp_get_multas_historico
-- Tipo: Report
-- Descripción: Obtiene el histórico de una multa
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

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