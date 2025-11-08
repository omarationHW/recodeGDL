-- Stored Procedure: sp16_operacion_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación si no tiene pagos asociados.
-- Generado para formulario: Cons_Cves_operacion
-- Fecha: 2025-08-27 14:00:02

CREATE OR REPLACE FUNCTION sp16_operacion_delete(p_ctrol_operacion INT)
RETURNS TABLE(status INT, leyenda TEXT) AS $$
DECLARE
  pagos INT;
BEGIN
  SELECT COUNT(*) INTO pagos FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion;
  IF pagos > 0 THEN
    RETURN QUERY SELECT 1, 'EXISTEN PAGOS CON ESTA CLAVE DE OPERACION, NO SE PUEDE BORRAR.';
    RETURN;
  END IF;
  DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
  RETURN QUERY SELECT 0, 'CLAVE DE OPERACION ELIMINADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;