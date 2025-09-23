-- Stored Procedure: sp_empresas_search
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre y/o tipo
-- Generado para formulario: ABC_Empresas
-- Fecha: 2025-08-27 13:23:03

CREATE OR REPLACE FUNCTION sp_empresas_search(p_descripcion VARCHAR DEFAULT NULL, p_ctrol_emp INTEGER DEFAULT NULL) RETURNS SETOF RECORD AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE (p_descripcion IS NULL OR a.descripcion ILIKE '%'||p_descripcion||'%')
      AND (p_ctrol_emp IS NULL OR a.ctrol_emp = p_ctrol_emp)
    ORDER BY a.descripcion, a.num_empresa, b.ctrol_emp;
END;
$$ LANGUAGE plpgsql;