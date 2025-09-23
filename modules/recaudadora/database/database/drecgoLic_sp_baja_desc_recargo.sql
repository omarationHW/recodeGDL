-- Stored Procedure: sp_baja_desc_recargo
-- Tipo: CRUD
-- Descripción: Cancela descuento de recargo
-- Generado para formulario: drecgoLic
-- Fecha: 2025-08-27 00:52:37

CREATE OR REPLACE FUNCTION sp_baja_desc_recargo(p_id_descto INTEGER, p_usuario VARCHAR) RETURNS VOID AS $$
BEGIN
  UPDATE descreclic SET estado='C', fecbaja=CURRENT_DATE, captbaja=p_usuario WHERE id_descto=p_id_descto;
END;
$$ LANGUAGE plpgsql;