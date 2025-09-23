-- Stored Procedure: sp_empresas_search
-- Tipo: Catalog
-- Descripción: Búsqueda flexible de empresas según opción (1: por número, 2: por nombre, 3: todas)
-- Generado para formulario: Cons_Empresas
-- Fecha: 2025-08-27 14:01:29

CREATE OR REPLACE FUNCTION sp_empresas_search(
    p_opcion INTEGER,
    p_num_empresa INTEGER DEFAULT NULL,
    p_ctrol_emp INTEGER DEFAULT NULL,
    p_nombre VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS $$
BEGIN
    IF p_opcion = 1 THEN
        RETURN QUERY
        SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
               b.tipo_empresa, b.descripcion
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        WHERE a.num_empresa = p_num_empresa AND a.ctrol_emp = p_ctrol_emp
        ORDER BY a.num_empresa, a.ctrol_emp;
    ELSIF p_opcion = 2 THEN
        RETURN QUERY
        SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
               b.tipo_empresa, b.descripcion
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        WHERE unaccent(upper(a.descripcion)) LIKE '%' || unaccent(upper(p_nombre)) || '%'
        ORDER BY a.descripcion, a.num_empresa, a.ctrol_emp;
    ELSE
        RETURN QUERY
        SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
               b.tipo_empresa, b.descripcion
        FROM ta_16_empresas a
        JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
        ORDER BY a.descripcion, a.num_empresa, a.ctrol_emp;
    END IF;
END;
$$ LANGUAGE plpgsql;