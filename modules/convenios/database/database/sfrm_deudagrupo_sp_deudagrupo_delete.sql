-- Stored Procedure: sp_deudagrupo_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de deudagrupo por id.
-- Generado para formulario: sfrm_deudagrupo
-- Fecha: 2025-08-27 15:55:12

CREATE OR REPLACE FUNCTION sp_deudagrupo_delete(p_id integer)
RETURNS TABLE(success boolean, message varchar) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM deudagrupo WHERE id = p_id;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false, 'Registro no encontrado';
  ELSE
    DELETE FROM deudagrupo WHERE id = p_id;
    RETURN QUERY SELECT true, 'Registro eliminado correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;