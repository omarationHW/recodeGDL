-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Cons_Empresas
-- Generado: 2025-08-27 14:01:29
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo y descripción
-- --------------------------------------------

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

-- ============================================

-- SP 2/5: sp_empresas_by_number
-- Tipo: Catalog
-- Descripción: Busca empresa por número y tipo
-- --------------------------------------------

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

-- ============================================

-- SP 3/5: sp_empresas_by_name
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE, insensible a mayúsculas)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_by_name(p_nombre VARCHAR)
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
    WHERE unaccent(upper(a.descripcion)) LIKE '%' || unaccent(upper(p_nombre)) || '%'
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_empresas_search
-- Tipo: Catalog
-- Descripción: Búsqueda flexible de empresas según opción (1: por número, 2: por nombre, 3: todas)
-- --------------------------------------------

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

-- ============================================

-- SP 5/5: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE (
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion
    FROM ta_16_tipos_emp
    ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

