-- Stored Procedure: sp_cancel_multa
-- Tipo: CRUD
-- Descripción: Cancela una multa y todos sus requerimientos asociados
-- Generado para formulario: consreqmulfrm
-- Fecha: 2025-08-26 23:43:36

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