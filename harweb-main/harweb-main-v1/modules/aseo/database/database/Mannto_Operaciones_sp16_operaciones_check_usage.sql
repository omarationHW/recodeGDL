-- Stored Procedure: sp16_operaciones_check_usage
-- Tipo: CRUD
-- Descripción: Verifica si una clave de operación tiene pagos asociados
-- Generado para formulario: Mannto_Operaciones
-- Fecha: 2025-08-27 14:45:58

CREATE OR REPLACE FUNCTION sp16_operaciones_check_usage(p_ctrol integer)
RETURNS JSON AS $$
DECLARE
  pagos integer;
BEGIN
  SELECT COUNT(*) INTO pagos FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol;
  RETURN json_build_object('success', true, 'in_use', pagos > 0);
END;
$$ LANGUAGE plpgsql;