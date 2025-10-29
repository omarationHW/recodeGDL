-- Stored Procedure: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo y descripción
-- Generado para formulario: Cons_Empresas
-- Fecha: 2025-08-27 14:01:29

CREATE OR REPLACE FUNCTION sp_empresas_list()
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
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
$$ LANGUAGE plpgsql;