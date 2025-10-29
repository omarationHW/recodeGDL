-- Stored Procedure: sp16_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa. Devuelve el registro insertado.
-- Generado para formulario: Cons_Tipos_Emp
-- Fecha: 2025-08-27 14:04:20

CREATE OR REPLACE FUNCTION sp16_tipos_emp_create(p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO ta_16_tipos_emp (tipo_empresa, descripcion)
  VALUES (p_tipo_empresa, p_descripcion)
  RETURNING ctrol_emp INTO new_id;
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp WHERE ctrol_emp = new_id;
END;
$$ LANGUAGE plpgsql;