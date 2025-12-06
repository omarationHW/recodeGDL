-- ==============================================================================
-- STORED PROCEDURES: CRUD Completo para Zonas Geográficas de Mercados
-- Base de Datos: padron_licencias
-- Esquema: comun
-- Tabla: comun.ta_12_zonas
-- Descripción: Mantenimiento de catálogo de zonas geográficas para mercados
-- ==============================================================================

-- ==============================================================================
-- SP: sp_zonas_list
-- Descripción: Lista todas las zonas geográficas
-- Parámetros: Ninguno
-- Retorna: Lista completa de zonas ordenadas por id_zona
-- ==============================================================================
DROP FUNCTION IF EXISTS public.sp_zonas_list();

CREATE OR REPLACE FUNCTION public.sp_zonas_list()
RETURNS TABLE (
    id_zona INTEGER,
    zona VARCHAR(30)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        z.id_zona,
        z.zona
    FROM comun.ta_12_zonas z
    ORDER BY z.id_zona;
END;
$$;

COMMENT ON FUNCTION public.sp_zonas_list() IS
'Lista todas las zonas geográficas disponibles para mercados';

-- ==============================================================================
-- SP: sp_zonas_get
-- Descripción: Obtiene una zona específica por ID
-- Parámetros:
--   p_id_zona INTEGER - ID de la zona a consultar
-- Retorna: Registro de la zona
-- ==============================================================================
DROP FUNCTION IF EXISTS public.sp_zonas_get(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_zonas_get(
    p_id_zona INTEGER
)
RETURNS TABLE (
    id_zona INTEGER,
    zona VARCHAR(30)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        z.id_zona,
        z.zona
    FROM comun.ta_12_zonas z
    WHERE z.id_zona = p_id_zona;
END;
$$;

COMMENT ON FUNCTION public.sp_zonas_get(INTEGER) IS
'Obtiene una zona geográfica específica por su ID';

-- ==============================================================================
-- SP: sp_zonas_create
-- Descripción: Crea una nueva zona geográfica
-- Parámetros:
--   p_id_zona INTEGER - ID de la nueva zona
--   p_zona VARCHAR - Nombre de la zona
-- Retorna: Registro creado
-- ==============================================================================
DROP FUNCTION IF EXISTS public.sp_zonas_create(INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_zonas_create(
    p_id_zona INTEGER,
    p_zona VARCHAR
)
RETURNS TABLE (
    id_zona INTEGER,
    zona VARCHAR(30),
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si ya existe el ID
    SELECT COUNT(*) INTO v_exists
    FROM comun.ta_12_zonas
    WHERE ta_12_zonas.id_zona = p_id_zona;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT NULL::INTEGER, NULL::VARCHAR(30), 'ERROR: Ya existe una zona con ese ID'::TEXT;
        RETURN;
    END IF;

    -- Insertar la nueva zona
    INSERT INTO comun.ta_12_zonas (id_zona, zona)
    VALUES (p_id_zona, p_zona);

    -- Retornar el registro creado
    RETURN QUERY
    SELECT
        z.id_zona,
        z.zona,
        'Zona creada exitosamente'::TEXT as message
    FROM comun.ta_12_zonas z
    WHERE z.id_zona = p_id_zona;
END;
$$;

COMMENT ON FUNCTION public.sp_zonas_create(INTEGER, VARCHAR) IS
'Crea una nueva zona geográfica para mercados';

-- ==============================================================================
-- SP: sp_zonas_update
-- Descripción: Actualiza una zona existente
-- Parámetros:
--   p_id_zona INTEGER - ID de la zona a actualizar
--   p_zona VARCHAR - Nuevo nombre de la zona
-- Retorna: Registro actualizado
-- ==============================================================================
DROP FUNCTION IF EXISTS public.sp_zonas_update(INTEGER, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_zonas_update(
    p_id_zona INTEGER,
    p_zona VARCHAR
)
RETURNS TABLE (
    id_zona INTEGER,
    zona VARCHAR(30),
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si existe la zona
    SELECT COUNT(*) INTO v_exists
    FROM comun.ta_12_zonas
    WHERE ta_12_zonas.id_zona = p_id_zona;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT NULL::INTEGER, NULL::VARCHAR(30), 'ERROR: No existe la zona especificada'::TEXT;
        RETURN;
    END IF;

    -- Actualizar la zona
    UPDATE comun.ta_12_zonas
    SET zona = p_zona
    WHERE ta_12_zonas.id_zona = p_id_zona;

    -- Retornar el registro actualizado
    RETURN QUERY
    SELECT
        z.id_zona,
        z.zona,
        'Zona actualizada exitosamente'::TEXT as message
    FROM comun.ta_12_zonas z
    WHERE z.id_zona = p_id_zona;
END;
$$;

COMMENT ON FUNCTION public.sp_zonas_update(INTEGER, VARCHAR) IS
'Actualiza el nombre de una zona geográfica existente';

-- ==============================================================================
-- SP: sp_zonas_delete
-- Descripción: Elimina una zona geográfica
-- Parámetros:
--   p_id_zona INTEGER - ID de la zona a eliminar
-- Retorna: Mensaje de confirmación o error
-- ==============================================================================
DROP FUNCTION IF EXISTS public.sp_zonas_delete(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_zonas_delete(
    p_id_zona INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists INTEGER;
    v_in_use INTEGER;
BEGIN
    -- Verificar si existe la zona
    SELECT COUNT(*) INTO v_exists
    FROM comun.ta_12_zonas
    WHERE ta_12_zonas.id_zona = p_id_zona;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'ERROR: No existe la zona especificada'::TEXT;
        RETURN;
    END IF;

    -- Verificar si la zona está en uso en mercados
    SELECT COUNT(*) INTO v_in_use
    FROM comun.ta_11_mercados
    WHERE zona = p_id_zona;

    IF v_in_use > 0 THEN
        RETURN QUERY SELECT FALSE, ('ERROR: La zona está en uso en ' || v_in_use || ' mercado(s)')::TEXT;
        RETURN;
    END IF;

    -- Eliminar la zona
    DELETE FROM comun.ta_12_zonas
    WHERE ta_12_zonas.id_zona = p_id_zona;

    RETURN QUERY SELECT TRUE, 'Zona eliminada exitosamente'::TEXT;
END;
$$;

COMMENT ON FUNCTION public.sp_zonas_delete(INTEGER) IS
'Elimina una zona geográfica si no está en uso por ningún mercado';
