-- Stored Procedure: sp_descmultalic_delete
-- Tipo: CRUD
-- Descripción: Elimina un descuento de multa de licencia
-- Generado para formulario: descmultalic
-- Fecha: 2025-08-27 00:04:06

CREATE OR REPLACE FUNCTION sp_descmultalic_delete(
    p_id_descto INTEGER
) RETURNS TABLE(id_descto INTEGER, message TEXT) AS $$
BEGIN
    DELETE FROM descmultalic WHERE id_descto = p_id_descto RETURNING id_descto, 'OK';
END;
$$ LANGUAGE plpgsql;