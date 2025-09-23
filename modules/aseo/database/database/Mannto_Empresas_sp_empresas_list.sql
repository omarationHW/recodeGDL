-- Stored Procedure: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo
-- Generado para formulario: Mannto_Empresas
-- Fecha: 2025-08-27 14:43:05

CREATE OR REPLACE FUNCTION sp_empresas_list()
RETURNS TABLE(num_empresa INT, ctrol_emp INT, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas ORDER BY num_empresa, ctrol_emp;
END;
$$ LANGUAGE plpgsql;