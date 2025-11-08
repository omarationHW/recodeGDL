-- Stored Procedure: sp_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa si no existe el tipo.
-- Generado para formulario: Mannto_Tipos_Emp
-- Fecha: 2025-08-27 14:52:22

CREATE OR REPLACE FUNCTION sp_tipos_emp_create(p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_tipos_emp WHERE tipo_empresa = p_tipo_empresa;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe el tipo de empresa';
    RETURN;
  END IF;
  INSERT INTO ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
    VALUES (DEFAULT, p_tipo_empresa, p_descripcion);
  RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente';
END;
$$ LANGUAGE plpgsql;