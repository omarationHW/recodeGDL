-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Empresas
-- Generado: 2025-08-27 13:23:03
-- Actualizado: 2025-12-08 - FIX ambiguedad usando alias de tabla
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_empresas_list
-- Tipo: Catalog
-- Descripcion: Lista todas las empresas con su tipo
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_empresas_list();

CREATE OR REPLACE FUNCTION sp_empresas_list()
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_empresa,
        e.ctrol_emp,
        t.tipo_empresa,
        e.descripcion,
        e.representante
    FROM ta_16_empresas e
    JOIN ta_16_tipos_emp t ON t.ctrol_emp = e.ctrol_emp
    ORDER BY e.descripcion, e.num_empresa, e.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_empresas_get
-- Tipo: Catalog
-- Descripcion: Obtiene una empresa por num_empresa y ctrol_emp
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_empresas_get(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION sp_empresas_get(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER
)
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_empresa,
        e.ctrol_emp,
        t.tipo_empresa,
        e.descripcion,
        e.representante
    FROM ta_16_empresas e
    JOIN ta_16_tipos_emp t ON t.ctrol_emp = e.ctrol_emp
    WHERE e.num_empresa = p_num_empresa
      AND e.ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_empresas_create
-- Tipo: CRUD
-- Descripcion: Crea una nueva empresa
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_empresas_create(INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION sp_empresas_create(
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR,
    p_representante VARCHAR
)
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER
) AS $$
DECLARE
    v_num_empresa INTEGER;
BEGIN
    SELECT COALESCE(MAX(e.num_empresa), 0) + 1
    INTO v_num_empresa
    FROM ta_16_empresas e
    WHERE e.ctrol_emp = p_ctrol_emp;

    INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_num_empresa, p_ctrol_emp, p_descripcion, p_representante);

    RETURN QUERY SELECT v_num_empresa, p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_empresas_update
-- Tipo: CRUD
-- Descripcion: Actualiza una empresa existente
-- FIX: Usar alias 'e' en WHERE para evitar ambiguedad
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_empresas_update(INTEGER, INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION sp_empresas_update(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_descripcion VARCHAR,
    p_representante VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    UPDATE ta_16_empresas e
    SET descripcion = p_descripcion,
        representante = p_representante
    WHERE e.num_empresa = p_num_empresa
      AND e.ctrol_emp = p_ctrol_emp;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Empresa actualizada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No se encontro la empresa'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_empresas_delete
-- Tipo: CRUD
-- Descripcion: Elimina una empresa si no tiene contratos asociados
-- FIX: Usar alias en WHERE para evitar ambiguedad
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_empresas_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION sp_empresas_delete(
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    -- Verificar si tiene contratos asociados
    SELECT COUNT(*) INTO v_contratos
    FROM ta_16_contratos c
    WHERE c.num_empresa = p_num_empresa
      AND c.ctrol_emp = p_ctrol_emp;

    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, ('No se puede eliminar: la empresa tiene ' || v_contratos || ' contrato(s) asociado(s)')::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_empresas e
    WHERE e.num_empresa = p_num_empresa
      AND e.ctrol_emp = p_ctrol_emp;

    IF FOUND THEN
        RETURN QUERY SELECT true, 'Empresa eliminada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT false, 'No se encontro la empresa'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_empresas_search
-- Tipo: Catalog
-- Descripcion: Busca empresas por nombre y/o tipo
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_empresas_search(VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION sp_empresas_search(
    p_descripcion VARCHAR DEFAULT NULL,
    p_ctrol_emp INTEGER DEFAULT NULL
)
RETURNS TABLE(
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR,
    representante VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.num_empresa,
        e.ctrol_emp,
        t.tipo_empresa,
        e.descripcion,
        e.representante
    FROM ta_16_empresas e
    JOIN ta_16_tipos_emp t ON t.ctrol_emp = e.ctrol_emp
    WHERE (p_descripcion IS NULL OR e.descripcion ILIKE '%' || p_descripcion || '%')
      AND (p_ctrol_emp IS NULL OR e.ctrol_emp = p_ctrol_emp)
    ORDER BY e.descripcion, e.num_empresa, e.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripcion: Lista todos los tipos de empresa
-- --------------------------------------------

DROP FUNCTION IF EXISTS sp_tipos_emp_list();

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE(
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.ctrol_emp, t.tipo_empresa, t.descripcion
    FROM ta_16_tipos_emp t
    ORDER BY t.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GRANT de permisos
-- ============================================
GRANT EXECUTE ON FUNCTION sp_empresas_list() TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_empresas_get(INTEGER, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_empresas_create(INTEGER, VARCHAR, VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_empresas_update(INTEGER, INTEGER, VARCHAR, VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_empresas_delete(INTEGER, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_empresas_search(VARCHAR, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION sp_tipos_emp_list() TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
