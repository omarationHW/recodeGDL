-- Stored Procedure: sp16_operaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva clave de operación si no existe
-- Generado para formulario: Mannto_Operaciones
-- Fecha: 2025-08-27 14:45:58

CREATE OR REPLACE FUNCTION sp16_operaciones_create(p_cve varchar, p_desc varchar)
RETURNS JSON AS $$
DECLARE
  existe integer;
  new_id integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE cve_operacion = p_cve;
  IF existe > 0 THEN
    RETURN json_build_object('success', false, 'message', 'Ya existe la clave de operación');
  END IF;
  INSERT INTO ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve, p_desc)
    RETURNING ctrol_operacion INTO new_id;
  RETURN json_build_object('success', true, 'message', 'Clave creada', 'ctrol_operacion', new_id);
END;
$$ LANGUAGE plpgsql;