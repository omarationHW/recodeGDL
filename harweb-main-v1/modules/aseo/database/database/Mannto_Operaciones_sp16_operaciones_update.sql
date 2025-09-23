-- Stored Procedure: sp16_operaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de operación
-- Generado para formulario: Mannto_Operaciones
-- Fecha: 2025-08-27 14:45:58

CREATE OR REPLACE FUNCTION sp16_operaciones_update(p_cve varchar, p_desc varchar)
RETURNS JSON AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE cve_operacion = p_cve;
  IF existe = 0 THEN
    RETURN json_build_object('success', false, 'message', 'No existe la clave de operación');
  END IF;
  UPDATE ta_16_operacion SET descripcion = p_desc WHERE cve_operacion = p_cve;
  RETURN json_build_object('success', true, 'message', 'Clave actualizada');
END;
$$ LANGUAGE plpgsql;