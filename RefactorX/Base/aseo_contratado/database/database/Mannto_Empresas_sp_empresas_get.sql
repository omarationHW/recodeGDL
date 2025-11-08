-- Stored Procedure: sp_empresas_get
-- Tipo: Catalog
-- Descripción: Obtiene una empresa por num_empresa y ctrol_emp
-- Generado para formulario: Mannto_Empresas
-- Fecha: 2025-08-27 14:43:05

CREATE OR REPLACE FUNCTION sp_empresas_get(p_num_empresa INT, p_ctrol_emp INT)
RETURNS TABLE(num_empresa INT, ctrol_emp INT, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;