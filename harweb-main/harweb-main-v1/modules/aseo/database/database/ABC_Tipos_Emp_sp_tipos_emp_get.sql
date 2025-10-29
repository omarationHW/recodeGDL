-- Stored Procedure: sp_tipos_emp_get
-- Tipo: Catalog
-- Descripción: Obtiene un tipo de empresa por su clave primaria
-- Generado para formulario: ABC_Tipos_Emp
-- Fecha: 2025-08-27 13:29:55

CREATE OR REPLACE FUNCTION sp_tipos_emp_get(p_ctrol_emp integer)
RETURNS TABLE(ctrol_emp integer, tipo_empresa varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;