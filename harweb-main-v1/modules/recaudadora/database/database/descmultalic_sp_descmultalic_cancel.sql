-- Stored Procedure: sp_descmultalic_cancel
-- Tipo: CRUD
-- Descripción: Cancela (marca como no vigente) un descuento de multa de licencia
-- Generado para formulario: descmultalic
-- Fecha: 2025-08-27 00:04:06

CREATE OR REPLACE FUNCTION sp_descmultalic_cancel(
    p_id_descto INTEGER,
    p_userbaja VARCHAR
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descmultalic
    SET vigencia = 'C', fecbaja = CURRENT_DATE, userbaja = p_userbaja
    WHERE id_descto = p_id_descto
    RETURNING id_descto, 'CANCELADO';
END;
$$ LANGUAGE plpgsql;