-- Stored Procedure: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo
-- Generado para formulario: ABC_Empresas
-- Fecha: 2025-08-27 13:23:03

CREATE OR REPLACE FUNCTION sp_empresas_list() RETURNS SETOF RECORD AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY a.descripcion, a.num_empresa, b.ctrol_emp;
END;
$$ LANGUAGE plpgsql;