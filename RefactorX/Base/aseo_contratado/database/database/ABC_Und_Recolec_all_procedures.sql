-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Und_Recolec
-- Base de datos: aseo_contratado
-- Tabla: ta_16_unidades
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- ============================================
-- Columnas REALES de la tabla (verificado con pg_catalog):
--   control_contrato (integer) PK
--   num_unidad (varchar 50)
--   tipo_unidad (varchar 50)
--   capacidad (numeric 10,2)
--   descripcion (text)
--   activo (boolean)
--   created_at (timestamp)
-- ============================================
-- NOTA: Los SPs mapean las columnas reales a los nombres
-- esperados por el frontend Vue (ctrol_recolec, cve_recolec, etc.)
-- ============================================

-- ============================================
-- SP 1/4: sp_unidades_recoleccion_list
-- Descripción: Lista todas las unidades de recolección
-- Mapeo: control_contrato -> ctrol_recolec
--        num_unidad -> cve_recolec
--        capacidad -> costo_unidad
-- ============================================
DROP FUNCTION IF EXISTS public.sp_unidades_recoleccion_list(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_unidades_recoleccion_list(p_ejercicio INTEGER DEFAULT NULL)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.control_contrato as ctrol_recolec,
           COALESCE(EXTRACT(YEAR FROM u.created_at)::SMALLINT, EXTRACT(YEAR FROM NOW())::SMALLINT) as ejercicio_recolec,
           u.num_unidad::VARCHAR as cve_recolec,
           u.descripcion::VARCHAR,
           u.capacidad as costo_unidad,
           0::NUMERIC as costo_exed
    FROM ta_16_unidades u
    WHERE u.activo = true OR u.activo IS NULL
    ORDER BY u.control_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_unidades_recoleccion_list(INTEGER) TO PUBLIC;

-- ============================================
-- SP 2/4: sp_unidades_recoleccion_create
-- Descripción: Crea una nueva unidad de recolección
-- Parámetros:
--   p_ejercicio: Año/ejercicio (no usado, compatibilidad)
--   p_cve: Clave de la unidad -> num_unidad
--   p_descripcion: Descripción
--   p_costo_unidad: Costo por unidad -> capacidad
--   p_costo_exed: Costo excedente (no usado)
--   p_usuario_id: ID del usuario (no usado)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_unidades_recoleccion_create(SMALLINT, VARCHAR, VARCHAR, NUMERIC, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_unidades_recoleccion_create(
    p_ejercicio SMALLINT,
    p_cve VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC,
    p_usuario_id INTEGER
)
RETURNS TABLE (status TEXT) AS $$
DECLARE
    v_next_id INTEGER;
BEGIN
    -- Obtener siguiente ID
    SELECT COALESCE(MAX(control_contrato), 0) + 1 INTO v_next_id FROM ta_16_unidades;

    INSERT INTO ta_16_unidades (control_contrato, num_unidad, tipo_unidad, descripcion, capacidad, activo, created_at)
    VALUES (v_next_id, p_cve, 'UNIDAD', p_descripcion, p_costo_unidad, true, NOW());

    RETURN QUERY SELECT 'ok'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_unidades_recoleccion_create(SMALLINT, VARCHAR, VARCHAR, NUMERIC, NUMERIC, INTEGER) TO PUBLIC;

-- ============================================
-- SP 3/4: sp_unidades_recoleccion_update
-- Descripción: Actualiza una unidad de recolección existente
-- Parámetros:
--   p_ctrol: ID de la unidad a actualizar -> control_contrato
--   p_ejercicio: Año/ejercicio (no usado)
--   p_cve: Nueva clave -> num_unidad
--   p_descripcion: Nueva descripción
--   p_costo_unidad: Nuevo costo -> capacidad
--   p_costo_exed: Nuevo costo excedente (no usado)
--   p_usuario_id: ID del usuario (no usado)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_unidades_recoleccion_update(INTEGER, SMALLINT, VARCHAR, VARCHAR, NUMERIC, NUMERIC, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_unidades_recoleccion_update(
    p_ctrol INTEGER,
    p_ejercicio SMALLINT,
    p_cve VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC,
    p_usuario_id INTEGER
)
RETURNS TABLE (status TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE control_contrato = p_ctrol;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'error: No existe la unidad'::TEXT;
        RETURN;
    END IF;

    UPDATE ta_16_unidades
    SET num_unidad = p_cve,
        descripcion = p_descripcion,
        capacidad = p_costo_unidad
    WHERE control_contrato = p_ctrol;

    RETURN QUERY SELECT 'ok'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_unidades_recoleccion_update(INTEGER, SMALLINT, VARCHAR, VARCHAR, NUMERIC, NUMERIC, INTEGER) TO PUBLIC;

-- ============================================
-- SP 4/4: sp_unidades_recoleccion_delete
-- Descripción: Elimina (desactiva) una unidad de recolección
-- Parámetros:
--   p_ctrol: ID de la unidad a eliminar -> control_contrato
-- ============================================
DROP FUNCTION IF EXISTS public.sp_unidades_recoleccion_delete(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_unidades_recoleccion_delete(p_ctrol INTEGER)
RETURNS TABLE (status TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE control_contrato = p_ctrol;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'error: No existe la unidad'::TEXT;
        RETURN;
    END IF;

    -- Soft delete - solo desactivar
    UPDATE ta_16_unidades SET activo = false WHERE control_contrato = p_ctrol;

    RETURN QUERY SELECT 'ok'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_unidades_recoleccion_delete(INTEGER) TO PUBLIC;
