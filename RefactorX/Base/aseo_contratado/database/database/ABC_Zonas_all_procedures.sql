-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Zonas
-- Base de datos: aseo_contratado
-- Tabla: ta_16_zonas
-- Actualizado: 2025-12-08
-- Total SPs: 4
-- ============================================
-- Columnas de la tabla:
--   ctrol_zona (integer) PK
--   zona (smallint)
--   sub_zona (smallint)
--   descripcion (varchar 2640)
-- ============================================

-- ============================================
-- SP 1/4: sp_zonas_list
-- Descripción: Lista todas las zonas ordenadas por zona y sub-zona
-- ============================================
DROP FUNCTION IF EXISTS public.sp_zonas_list();

CREATE OR REPLACE FUNCTION public.sp_zonas_list()
RETURNS TABLE (
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT z.ctrol_zona, z.zona, z.sub_zona, z.descripcion::VARCHAR
    FROM ta_16_zonas z
    ORDER BY z.zona, z.sub_zona, z.ctrol_zona;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_zonas_list() TO PUBLIC;

-- ============================================
-- SP 2/4: sp_zonas_create
-- Descripción: Crea una nueva zona en el catálogo
-- Parámetros:
--   p_zona: Número de zona
--   p_sub_zona: Número de sub-zona
--   p_descripcion: Descripción de la zona
-- ============================================
DROP FUNCTION IF EXISTS public.sp_zonas_create(INTEGER, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_zonas_create(
    p_zona INTEGER,
    p_sub_zona INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE (
    ctrol_zona INTEGER,
    zona INTEGER,
    sub_zona INTEGER,
    descripcion VARCHAR
) AS $$
DECLARE
    v_new_ctrol INTEGER;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_zonas z WHERE z.zona = p_zona AND z.sub_zona = p_sub_zona) THEN
        RAISE EXCEPTION 'Ya existe una zona con esos datos';
    END IF;

    -- Obtener siguiente ID
    SELECT COALESCE(MAX(z.ctrol_zona), 0) + 1 INTO v_new_ctrol FROM ta_16_zonas z;

    -- Insertar
    INSERT INTO ta_16_zonas (ctrol_zona, zona, sub_zona, descripcion)
    VALUES (v_new_ctrol, p_zona::SMALLINT, p_sub_zona::SMALLINT, p_descripcion);

    RETURN QUERY SELECT v_new_ctrol, p_zona, p_sub_zona, p_descripcion;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_zonas_create(INTEGER, INTEGER, VARCHAR) TO PUBLIC;

-- ============================================
-- SP 3/4: sp_zonas_update
-- Descripción: Actualiza una zona existente
-- Parámetros:
--   p_ctrol_zona: ID de la zona a actualizar
--   p_zona: Nuevo número de zona
--   p_sub_zona: Nuevo número de sub-zona
--   p_descripcion: Nueva descripción
-- ============================================
DROP FUNCTION IF EXISTS public.sp_zonas_update(INTEGER, INTEGER, INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_zonas_update(
    p_ctrol_zona INTEGER,
    p_zona INTEGER,
    p_sub_zona INTEGER,
    p_descripcion VARCHAR
)
RETURNS TABLE (
    ctrol_zona INTEGER,
    zona INTEGER,
    sub_zona INTEGER,
    descripcion VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar existencia
    SELECT COUNT(*) INTO v_exists FROM ta_16_zonas z WHERE z.ctrol_zona = p_ctrol_zona;

    IF v_exists = 0 THEN
        RAISE EXCEPTION 'No existe la zona con ID %', p_ctrol_zona;
    END IF;

    -- Actualizar
    UPDATE ta_16_zonas z
    SET zona = p_zona::SMALLINT,
        sub_zona = p_sub_zona::SMALLINT,
        descripcion = p_descripcion
    WHERE z.ctrol_zona = p_ctrol_zona;

    RETURN QUERY SELECT p_ctrol_zona, p_zona, p_sub_zona, p_descripcion;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_zonas_update(INTEGER, INTEGER, INTEGER, VARCHAR) TO PUBLIC;

-- ============================================
-- SP 4/4: sp_zonas_delete
-- Descripción: Elimina una zona si no tiene empresas relacionadas
-- Parámetros:
--   p_ctrol_zona: ID de la zona a eliminar
-- ============================================
DROP FUNCTION IF EXISTS public.sp_zonas_delete(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_zonas_delete(p_ctrol_zona INTEGER)
RETURNS TABLE (status TEXT, message TEXT) AS $$
DECLARE
    v_emp_count INTEGER;
BEGIN
    -- Verificar empresas asociadas
    SELECT COUNT(*) INTO v_emp_count FROM ta_16_empresas e WHERE e.ctrol_zona = p_ctrol_zona;

    IF v_emp_count > 0 THEN
        RETURN QUERY SELECT 'error'::TEXT, ('No se puede eliminar: tiene ' || v_emp_count || ' empresa(s) asociada(s)')::TEXT;
        RETURN;
    END IF;

    -- Eliminar
    DELETE FROM ta_16_zonas z WHERE z.ctrol_zona = p_ctrol_zona;

    IF FOUND THEN
        RETURN QUERY SELECT 'success'::TEXT, 'Zona eliminada correctamente'::TEXT;
    ELSE
        RETURN QUERY SELECT 'error'::TEXT, 'No existe la zona'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_zonas_delete(INTEGER) TO PUBLIC;
