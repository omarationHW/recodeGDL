-- Stored Procedure: sp16_tipos_emp_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de empresa existente.
-- Generado para formulario: Cons_Tipos_Emp
-- Fecha: 2025-08-27 14:04:20

CREATE OR REPLACE FUNCTION sp16_tipos_emp_update(p_ctrol_emp INTEGER, p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  UPDATE ta_16_tipos_emp
     SET tipo_empresa = p_tipo_empresa,
         descripcion = p_descripcion
   WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;