-- Stored Procedure: sp_get_multas_by_id
-- Tipo: CRUD
-- Descripción: Obtiene una multa por su ID
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

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