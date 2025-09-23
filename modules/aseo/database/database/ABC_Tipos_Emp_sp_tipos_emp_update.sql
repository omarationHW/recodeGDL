-- Stored Procedure: sp_tipos_emp_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de empresa existente
-- Generado para formulario: ABC_Tipos_Emp
-- Fecha: 2025-08-27 13:29:55

CREATE OR REPLACE FUNCTION sp_tipos_emp_update(p_ctrol_emp integer, p_tipo_empresa varchar, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false, 'No existe el tipo de empresa';
    RETURN;
  END IF;
  UPDATE ta_16_tipos_emp SET tipo_empresa = p_tipo_empresa, descripcion = p_descripcion
    WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa actualizado correctamente';
END;
$$ LANGUAGE plpgsql;