-- Stored Procedure: sp_empresas_by_number
-- Tipo: Catalog
-- Descripción: Busca empresa por número y tipo
-- Generado para formulario: Cons_Empresas
-- Fecha: 2025-08-27 14:01:29

CREATE OR REPLACE FUNCTION sp_empresas_by_number(p_num_empresa INTEGER, p_ctrol_emp INTEGER)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
$$ LANGUAGE plpgsql;