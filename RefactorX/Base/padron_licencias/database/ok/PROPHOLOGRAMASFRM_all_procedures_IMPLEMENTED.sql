-- ============================================
-- IMPLEMENTACION COMPLETA: prophologramasfrm
-- Componente: Gestión de Hologramas de Contribuyentes
-- Fecha: 2025-11-20
-- Total SPs: 4
-- Schema: public
-- Tabla: c_contribholog
-- ============================================

-- ============================================
-- SP 1/4: sp_contribholog_list
-- Descripción: Lista todos los contribuyentes con hologramas
-- Parámetros: p_filtro (opcional) - Filtro por nombre o RFC
-- Retorna: Lista completa de contribuyentes con hologramas
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_contribholog_list(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ch.idcontrib,
        ch.nombre,
        ch.domicilio,
        ch.colonia,
        ch.telefono,
        ch.rfc,
        ch.curp,
        ch.email,
        ch.feccap,
        ch.capturista
    FROM public.c_contribholog ch
    WHERE (p_filtro IS NULL OR
           UPPER(TRIM(ch.nombre)) LIKE '%' || UPPER(TRIM(p_filtro)) || '%' OR
           UPPER(TRIM(ch.rfc)) LIKE '%' || UPPER(TRIM(p_filtro)) || '%' OR
           UPPER(TRIM(ch.curp)) LIKE '%' || UPPER(TRIM(p_filtro)) || '%')
    ORDER BY ch.nombre;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_contribholog_list(VARCHAR) IS
'Lista contribuyentes con hologramas - Soporta filtro por nombre, RFC o CURP';


-- ============================================
-- SP 2/4: sp_contribholog_create
-- Descripción: Crea un nuevo registro de contribuyente con holograma
-- Validaciones:
--   - RFC formato válido (12-13 caracteres alfanuméricos)
--   - Nombre no vacío
--   - Prevención de duplicados por RFC
--   - Normalización automática UPPER/TRIM
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_contribholog_create(
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_colonia VARCHAR,
    p_telefono VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_email VARCHAR,
    p_capturista VARCHAR
) RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_idcontrib INTEGER;
    v_rfc_normalizado VARCHAR;
    v_nombre_normalizado VARCHAR;
    v_rfc_existente INTEGER;
BEGIN
    -- Validación: Nombre no vacío
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del contribuyente es obligatorio';
    END IF;

    -- Normalización de datos
    v_nombre_normalizado := UPPER(TRIM(p_nombre));
    v_rfc_normalizado := UPPER(TRIM(p_rfc));

    -- Validación: RFC formato válido (12-13 caracteres)
    IF v_rfc_normalizado IS NOT NULL AND
       (LENGTH(v_rfc_normalizado) < 12 OR LENGTH(v_rfc_normalizado) > 13) THEN
        RAISE EXCEPTION 'El RFC debe tener entre 12 y 13 caracteres';
    END IF;

    -- Validación: RFC no debe estar duplicado
    IF v_rfc_normalizado IS NOT NULL AND v_rfc_normalizado != '' THEN
        SELECT COUNT(*) INTO v_rfc_existente
        FROM public.c_contribholog
        WHERE UPPER(TRIM(rfc)) = v_rfc_normalizado;

        IF v_rfc_existente > 0 THEN
            RAISE EXCEPTION 'Ya existe un contribuyente registrado con el RFC: %', v_rfc_normalizado;
        END IF;
    END IF;

    -- Inserción con datos normalizados
    INSERT INTO public.c_contribholog (
        nombre,
        domicilio,
        colonia,
        telefono,
        rfc,
        curp,
        email,
        feccap,
        capturista
    )
    VALUES (
        v_nombre_normalizado,
        TRIM(p_domicilio),
        TRIM(p_colonia),
        TRIM(p_telefono),
        v_rfc_normalizado,
        UPPER(TRIM(p_curp)),
        LOWER(TRIM(p_email)),
        NOW(),
        TRIM(p_capturista)
    )
    RETURNING c_contribholog.idcontrib INTO v_idcontrib;

    -- Retornar el registro insertado
    RETURN QUERY
    SELECT
        c.idcontrib,
        c.nombre,
        c.domicilio,
        c.colonia,
        c.telefono,
        c.rfc,
        c.curp,
        c.email,
        c.feccap,
        c.capturista
    FROM public.c_contribholog c
    WHERE c.idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_contribholog_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
'Crea nuevo contribuyente con holograma - Validaciones: RFC único, nombre obligatorio, normalización automática';


-- ============================================
-- SP 3/4: sp_contribholog_update
-- Descripción: Actualiza un registro de contribuyente con holograma
-- Validaciones:
--   - RFC formato válido (12-13 caracteres alfanuméricos)
--   - Nombre no vacío
--   - Prevención de duplicados por RFC (excepto mismo registro)
--   - Normalización automática UPPER/TRIM
--   - Existencia del registro
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_contribholog_update(
    p_idcontrib INTEGER,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_colonia VARCHAR,
    p_telefono VARCHAR,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_email VARCHAR,
    p_capturista VARCHAR
) RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_rfc_normalizado VARCHAR;
    v_nombre_normalizado VARCHAR;
    v_rfc_existente INTEGER;
    v_registro_existente INTEGER;
BEGIN
    -- Validación: El registro debe existir
    SELECT COUNT(*) INTO v_registro_existente
    FROM public.c_contribholog
    WHERE c_contribholog.idcontrib = p_idcontrib;

    IF v_registro_existente = 0 THEN
        RAISE EXCEPTION 'No existe el contribuyente con ID: %', p_idcontrib;
    END IF;

    -- Validación: Nombre no vacío
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del contribuyente es obligatorio';
    END IF;

    -- Normalización de datos
    v_nombre_normalizado := UPPER(TRIM(p_nombre));
    v_rfc_normalizado := UPPER(TRIM(p_rfc));

    -- Validación: RFC formato válido (12-13 caracteres)
    IF v_rfc_normalizado IS NOT NULL AND
       (LENGTH(v_rfc_normalizado) < 12 OR LENGTH(v_rfc_normalizado) > 13) THEN
        RAISE EXCEPTION 'El RFC debe tener entre 12 y 13 caracteres';
    END IF;

    -- Validación: RFC no debe estar duplicado en otro registro
    IF v_rfc_normalizado IS NOT NULL AND v_rfc_normalizado != '' THEN
        SELECT COUNT(*) INTO v_rfc_existente
        FROM public.c_contribholog
        WHERE UPPER(TRIM(rfc)) = v_rfc_normalizado
          AND idcontrib != p_idcontrib;

        IF v_rfc_existente > 0 THEN
            RAISE EXCEPTION 'Ya existe otro contribuyente registrado con el RFC: %', v_rfc_normalizado;
        END IF;
    END IF;

    -- Actualización con datos normalizados
    UPDATE public.c_contribholog
    SET nombre = v_nombre_normalizado,
        domicilio = TRIM(p_domicilio),
        colonia = TRIM(p_colonia),
        telefono = TRIM(p_telefono),
        rfc = v_rfc_normalizado,
        curp = UPPER(TRIM(p_curp)),
        email = LOWER(TRIM(p_email)),
        capturista = TRIM(p_capturista)
    WHERE c_contribholog.idcontrib = p_idcontrib;

    -- Retornar el registro actualizado
    RETURN QUERY
    SELECT
        c.idcontrib,
        c.nombre,
        c.domicilio,
        c.colonia,
        c.telefono,
        c.rfc,
        c.curp,
        c.email,
        c.feccap,
        c.capturista
    FROM public.c_contribholog c
    WHERE c.idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_contribholog_update(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
'Actualiza contribuyente con holograma - Validaciones: RFC único, nombre obligatorio, normalización automática, existencia del registro';


-- ============================================
-- SP 4/4: sp_contribholog_delete
-- Descripción: Elimina un registro de contribuyente con holograma
-- Tipo: Eliminación física (hard delete)
-- Validaciones:
--   - Existencia del registro antes de eliminar
--   - Retorna el registro eliminado para confirmación
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_contribholog_delete(
    p_idcontrib INTEGER
)
RETURNS TABLE (
    idcontrib INTEGER,
    nombre VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    telefono VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    email VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_row RECORD;
BEGIN
    -- Obtener el registro antes de eliminarlo
    SELECT * INTO v_row
    FROM public.c_contribholog
    WHERE c_contribholog.idcontrib = p_idcontrib;

    -- Validación: El registro debe existir
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe el contribuyente con ID: %', p_idcontrib;
    END IF;

    -- Eliminación física del registro
    DELETE FROM public.c_contribholog
    WHERE c_contribholog.idcontrib = p_idcontrib;

    -- Retornar el registro eliminado
    RETURN QUERY
    SELECT
        v_row.idcontrib,
        v_row.nombre,
        v_row.domicilio,
        v_row.colonia,
        v_row.telefono,
        v_row.rfc,
        v_row.curp,
        v_row.email,
        v_row.feccap,
        v_row.capturista;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_contribholog_delete(INTEGER) IS
'Elimina contribuyente con holograma - Eliminación física, validación de existencia, retorna registro eliminado';


-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Total SPs implementados: 4
-- Schema: public
-- Tabla principal: c_contribholog
--
-- CARACTERÍSTICAS PRINCIPALES:
-- 1. Normalización automática de datos (UPPER/TRIM)
-- 2. Validación de RFC (12-13 caracteres, único)
-- 3. Validación de nombre obligatorio
-- 4. Búsqueda flexible por nombre, RFC o CURP
-- 5. Eliminación física con validación de existencia
-- 6. Fecha de captura automática (feccap = NOW())
-- 7. Email normalizado en minúsculas
-- 8. Manejo de excepciones con mensajes descriptivos
--
-- NOMENCLATURA:
-- - Prefijo: sp_contribholog_
-- - Parámetros: p_
-- - Variables: v_
--
-- VALIDACIONES IMPLEMENTADAS:
-- - RFC: 12-13 caracteres, único en BD
-- - Nombre: No vacío, normalizado UPPER
-- - Email: Normalizado LOWER
-- - Duplicados: Prevención por RFC
-- - Existencia: Validación en UPDATE y DELETE
-- ============================================
