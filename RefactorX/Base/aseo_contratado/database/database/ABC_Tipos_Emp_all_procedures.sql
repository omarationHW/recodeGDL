-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Tipos_Emp
-- Base de datos: aseo_contratado
-- Tabla: ta_16_tipos_emp
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- ============================================
-- Columnas de la tabla:
--   ctrol_emp (integer) PK
--   tipo_empresa (character)
--   descripcion (varchar)
-- ============================================

-- ============================================
-- SP 1/4: sp_tipos_emp_list
-- Descripción: Lista todos los tipos de empresa
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_emp_list();

CREATE OR REPLACE FUNCTION public.sp_tipos_emp_list()
RETURNS TABLE (
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT t.ctrol_emp, t.tipo_empresa::VARCHAR, t.descripcion
    FROM ta_16_tipos_emp t
    ORDER BY t.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_emp_list() TO PUBLIC;

-- ============================================
-- SP 2/4: sp_tipos_emp_create
-- Descripción: Crea un nuevo tipo de empresa
-- Parámetros:
--   p_ctrol_emp: ID del tipo
--   p_tipo_empresa: Código/letra del tipo
--   p_descripcion: Descripción del tipo
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_emp_create(INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_tipos_emp_create(
    p_ctrol_emp INTEGER,
    p_tipo_empresa VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipos_emp t
    WHERE t.ctrol_emp = p_ctrol_emp;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un tipo con ese control'::TEXT;
        RETURN;
    END IF;

    INSERT INTO ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
    VALUES (p_ctrol_emp, p_tipo_empresa, p_descripcion);

    RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_emp_create(INTEGER, VARCHAR, VARCHAR) TO PUBLIC;

-- ============================================
-- SP 3/4: sp_tipos_emp_update
-- Descripción: Actualiza un tipo de empresa existente
-- Parámetros:
--   p_ctrol_emp: ID del tipo a actualizar
--   p_tipo_empresa: Nuevo código/letra
--   p_descripcion: Nueva descripción
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_emp_update(INTEGER, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_tipos_emp_update(
    p_ctrol_emp INTEGER,
    p_tipo_empresa VARCHAR,
    p_descripcion VARCHAR
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipos_emp t
    WHERE t.ctrol_emp = p_ctrol_emp;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de empresa'::TEXT;
        RETURN;
    END IF;

    UPDATE ta_16_tipos_emp t
    SET tipo_empresa = p_tipo_empresa,
        descripcion = p_descripcion
    WHERE t.ctrol_emp = p_ctrol_emp;

    RETURN QUERY SELECT true, 'Tipo de empresa actualizado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_emp_update(INTEGER, VARCHAR, VARCHAR) TO PUBLIC;

-- ============================================
-- SP 4/4: sp_tipos_emp_delete
-- Descripción: Elimina un tipo de empresa si no tiene empresas asociadas
-- Parámetros:
--   p_ctrol_emp: ID del tipo a eliminar
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_emp_delete(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_tipos_emp_delete(
    p_ctrol_emp INTEGER
)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
    v_empresas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipos_emp t
    WHERE t.ctrol_emp = p_ctrol_emp;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de empresa'::TEXT;
        RETURN;
    END IF;

    -- Verificar empresas asociadas
    SELECT COUNT(*) INTO v_empresas
    FROM ta_16_empresas e
    WHERE e.tipo_empresa = p_ctrol_emp;

    IF v_empresas > 0 THEN
        RETURN QUERY SELECT false, ('No se puede eliminar: tiene ' || v_empresas || ' empresa(s) asociada(s)')::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_tipos_emp t
    WHERE t.ctrol_emp = p_ctrol_emp;

    RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_emp_delete(INTEGER) TO PUBLIC;
