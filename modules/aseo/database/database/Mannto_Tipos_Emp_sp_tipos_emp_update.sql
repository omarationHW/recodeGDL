-- Stored Procedure: sp_tipos_emp_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo de empresa.
-- Generado para formulario: Mannto_Tipos_Emp
-- Fecha: 2025-08-27 14:52:22

CREATE OR REPLACE FUNCTION sp_tipos_emp_update(p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_tipos_emp WHERE tipo_empresa = p_tipo_empresa;
  IF existe = 0 THEN
    RETURN QUERY SELECT false, 'No existe el tipo de empresa';
    RETURN;
  END IF;
  UPDATE ta_16_tipos_emp SET descripcion = p_descripcion WHERE tipo_empresa = p_tipo_empresa;
  RETURN QUERY SELECT true, 'Tipo de empresa actualizado correctamente';
END;
$$ LANGUAGE plpgsql;