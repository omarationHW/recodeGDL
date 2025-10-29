-- Stored Procedure: sp16_operaciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación si no tiene pagos asociados
-- Generado para formulario: Mannto_Operaciones
-- Fecha: 2025-08-27 14:45:58

CREATE OR REPLACE FUNCTION sp16_operaciones_delete(p_ctrol integer)
RETURNS JSON AS $$
DECLARE
  pagos integer;
BEGIN
  SELECT COUNT(*) INTO pagos FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol;
  IF pagos > 0 THEN
    RETURN json_build_object('success', false, 'message', 'No se puede eliminar: existen pagos asociados');
  END IF;
  DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol;
  RETURN json_build_object('success', true, 'message', 'Clave eliminada');
END;
$$ LANGUAGE plpgsql;