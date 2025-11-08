-- Stored Procedure: sp_empresas_get
-- Tipo: Catalog
-- Descripción: Obtiene una empresa por num_empresa y ctrol_emp
-- Generado para formulario: ABC_Empresas
-- Fecha: 2025-08-27 13:23:03

CREATE OR REPLACE FUNCTION sp_empresas_get(p_num_empresa INTEGER, p_ctrol_emp INTEGER) RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;