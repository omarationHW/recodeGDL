-- Stored Procedure: sp_baja_desc_multa
-- Tipo: CRUD
-- Descripción: Cancela descuento de multa
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_baja_desc_multa(p_id_descto INTEGER, p_usuario VARCHAR) RETURNS VOID AS $$
BEGIN
  UPDATE descmultalic SET vigencia='C', fecbaja=CURRENT_DATE, userbaja=p_usuario WHERE id_descto=p_id_descto;
END;
$$ LANGUAGE plpgsql;