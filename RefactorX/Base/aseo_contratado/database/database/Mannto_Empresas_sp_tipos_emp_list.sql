-- Stored Procedure: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- Generado para formulario: Mannto_Empresas
-- Fecha: 2025-08-27 14:43:05

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE(ctrol_emp INT, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;