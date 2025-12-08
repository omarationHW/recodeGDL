-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Tipos_Aseo
-- Base de datos: aseo_contratado
-- Tabla: ta_16_tipo_aseo
-- Actualizado: 2025-12-07
-- Total SPs: 4
-- ============================================
-- Columnas de la tabla:
--   ctrol_aseo (integer) PK
--   tipo_aseo (character)
--   descripcion (varchar)
--   cta_aplicacion (integer)
--   cta_apl_rezago (integer)
--   cta_apl_exed (integer)
--   cta_apl_exed_rez (integer)
-- ============================================

-- ============================================
-- SP 1/4: sp_tipos_aseo_list
-- Descripción: Lista todos los tipos de aseo ordenados por control
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_aseo_list();

CREATE OR REPLACE FUNCTION public.sp_tipos_aseo_list()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT t.ctrol_aseo, t.tipo_aseo::VARCHAR, t.descripcion, t.cta_aplicacion
    FROM ta_16_tipo_aseo t
    ORDER BY t.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_aseo_list() TO PUBLIC;

-- ============================================
-- SP 2/4: sp_tipos_aseo_create
-- Descripción: Alta de un nuevo tipo de aseo
-- Parámetros:
--   p_tipo_aseo: Letra/código del tipo (1 caracter)
--   p_descripcion: Descripción del tipo
--   p_cta_aplicacion: Cuenta de aplicación (opcional)
--   p_usuario: ID del usuario (no usado, mantenido por compatibilidad)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_aseo_create(VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_tipos_aseo_create(
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, msg TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipo_aseo t
    WHERE t.tipo_aseo = p_tipo_aseo;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo'::TEXT;
        RETURN;
    END IF;

    INSERT INTO ta_16_tipo_aseo (tipo_aseo, descripcion, cta_aplicacion)
    VALUES (p_tipo_aseo, p_descripcion, p_cta_aplicacion);

    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_aseo_create(VARCHAR, VARCHAR, INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- SP 3/4: sp_tipos_aseo_update
-- Descripción: Actualiza un tipo de aseo existente
-- Parámetros:
--   p_ctrol_aseo: ID del tipo a actualizar
--   p_tipo_aseo: Nuevo código del tipo
--   p_descripcion: Nueva descripción
--   p_cta_aplicacion: Nueva cuenta de aplicación
--   p_usuario: ID del usuario (no usado, mantenido por compatibilidad)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_aseo_update(INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_tipos_aseo_update(
    p_ctrol_aseo INTEGER,
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, msg TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipo_aseo t
    WHERE t.ctrol_aseo = p_ctrol_aseo;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo'::TEXT;
        RETURN;
    END IF;

    UPDATE ta_16_tipo_aseo t
    SET tipo_aseo = p_tipo_aseo,
        descripcion = p_descripcion,
        cta_aplicacion = p_cta_aplicacion
    WHERE t.ctrol_aseo = p_ctrol_aseo;

    RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_aseo_update(INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- SP 4/4: sp_tipos_aseo_delete
-- Descripción: Elimina un tipo de aseo si no tiene contratos asociados
-- Parámetros:
--   p_ctrol_aseo: ID del tipo a eliminar
--   p_usuario: ID del usuario (no usado, mantenido por compatibilidad)
-- ============================================
DROP FUNCTION IF EXISTS public.sp_tipos_aseo_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_tipos_aseo_delete(
    p_ctrol_aseo INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (success BOOLEAN, msg TEXT) AS $$
DECLARE
    v_exists INTEGER;
    v_has_contracts INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM ta_16_tipo_aseo t
    WHERE t.ctrol_aseo = p_ctrol_aseo;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo'::TEXT;
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_has_contracts
    FROM ta_16_contratos c
    WHERE c.ctrol_aseo = p_ctrol_aseo;

    IF v_has_contracts > 0 THEN
        RETURN QUERY SELECT false, ('No se puede eliminar: tiene ' || v_has_contracts || ' contrato(s) asociado(s)')::TEXT;
        RETURN;
    END IF;

    DELETE FROM ta_16_tipo_aseo t
    WHERE t.ctrol_aseo = p_ctrol_aseo;

    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_tipos_aseo_delete(INTEGER, INTEGER) TO PUBLIC;
