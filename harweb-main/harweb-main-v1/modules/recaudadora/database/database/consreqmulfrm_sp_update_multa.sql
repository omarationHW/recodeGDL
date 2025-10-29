-- Stored Procedure: sp_update_multa
-- Tipo: CRUD
-- Descripción: Actualiza los datos de una multa
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

CREATE OR REPLACE FUNCTION sp_update_multa(
    p_id_multa INTEGER,
    p_calificacion NUMERIC,
    p_multa NUMERIC,
    p_comentario TEXT,
    p_user TEXT
) RETURNS VOID AS $$
BEGIN
    UPDATE multas SET calificacion = p_calificacion, multa = p_multa, comentario = p_comentario, capturista = p_user, updated_at = NOW()
    WHERE id_multa = p_id_multa;
END;
$$ LANGUAGE plpgsql;