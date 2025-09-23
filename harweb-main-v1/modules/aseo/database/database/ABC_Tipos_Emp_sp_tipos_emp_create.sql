-- Stored Procedure: sp_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa
-- Generado para formulario: ABC_Tipos_Emp
-- Fecha: 2025-08-27 13:29:55

CREATE OR REPLACE FUNCTION sp_tipos_emp_create(p_ctrol_emp integer, p_tipo_empresa varchar, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe un tipo de empresa con ese control';
    RETURN;
  END IF;
  INSERT INTO ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
  VALUES (p_ctrol_emp, p_tipo_empresa, p_descripcion);
  RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente';
END;
$$ LANGUAGE plpgsql;