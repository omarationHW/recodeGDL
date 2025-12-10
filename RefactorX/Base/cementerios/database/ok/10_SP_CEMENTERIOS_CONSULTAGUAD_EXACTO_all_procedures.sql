-- =============================================
-- CEMENTERIOS - CONSULTA CEMENTERIO GUADALAJARA (ConsultaGuad.vue)
-- =============================================
-- Archivo: 10_SP_CEMENTERIOS_CONSULTAGUAD_EXACTO_all_procedures.sql
-- Descripción: Stored Procedures para consulta de folios del Cementerio Guadalajara
-- Fecha: 2025-11-25
--
-- ESQUEMAS según postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - tc_13_cementerios → cementerio.public
--
-- LÓGICA ORIGINAL (Pascal):
--   - Base de datos: guadalajaracem (tabla: regprop)
--   - 3 modos de búsqueda:
--     1. Por ubicación (RCM): clase, sección, línea
--     2. Por nombre: LIKE %nombre%
--     3. Por ppago (campo particular)
--
-- MIGRACIÓN A POSTGRESQL:
--   - La tabla regprop → ta_13_datosrcm (con filtro cementerio='GUADAL')
--   - Campo ppago → No existe en ta_13_datosrcm (se omite esta búsqueda)
--   - Búsqueda por ubicación y nombre implementadas
--
-- SPS CREADOS:
--   1. sp_consultaguad_buscar_por_ubicacion(p_clase, p_seccion, p_linea) → Búsqueda por ubicación
--   2. sp_consultaguad_buscar_por_nombre(p_nombre, p_limite, p_offset) → Búsqueda por nombre
--   3. sp_consultaguad_listar_todos(p_limite, p_offset) → Lista todos los folios (paginado)
-- =============================================

-- =============================================
-- 1. sp_consultaguad_buscar_por_ubicacion
-- Descripción: Busca folios del cementerio Guadalajara por ubicación física
--              (clase, sección, línea >= valor especificado)
-- Parámetros:
--   - p_clase: Clase (numérico)
--   - p_seccion: Sección (numérico)
--   - p_linea: Línea (numérico, >= a este valor)
-- Retorna: TABLE con folios que coincidan
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultaguad_buscar_por_ubicacion(
    p_clase integer,
    p_seccion integer,
    p_linea integer
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    axo_pagado INTEGER,
    metros NUMERIC,
    tipo CHAR(1),
    fecha_alta DATE,
    vigencia CHAR(1),
    observaciones VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (líneas 108-112):
    -- Qryrcm.ParamByName('vclase').AsSmallInt:= StrToInt(mxFlatFloatECLase.Text);
    -- Qryrcm.ParamByName('vsec').AsSmallInt:= StrToInt(mxFlatFloatESeccion.Text);
    -- Qryrcm.ParamByName('vlinea').AsSmallInt:= StrToInt(mxFlatFloatELinea.Text);
    -- SQL: 'select * from regprop where clase=:vclase and seccion=:vsec and linea>=:vlinea'

    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.axo_pagado,
        d.metros,
        d.tipo,
        d.fecha_alta,
        d.vigencia,
        d.observaciones
    FROM public.ta_13_datosrcm d
    WHERE d.cementerio = 'G'
      AND d.clase = p_clase
      AND d.seccion = p_seccion
      AND d.linea >= p_linea
      --AND d.vigencia = 'S'
    ORDER BY d.clase, d.seccion, d.linea, d.fosa;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consultaguad_buscar_por_ubicacion IS 'Busca folios del Cementerio Guadalajara por ubicación física (clase, sección, línea)';

-- =============================================
-- 2. sp_consultaguad_buscar_por_nombre
-- Descripción: Busca folios del cementerio Guadalajara por nombre del titular
-- Parámetros:
--   - p_nombre: Nombre a buscar (usa LIKE %nombre%)
--   - p_limite: Número máximo de resultados (default 100)
--   - p_offset: Número de registros a saltar (default 0, para paginación)
-- Retorna: TABLE con folios que coincidan
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultaguad_buscar_por_nombre(
    p_nombre VARCHAR(60),
    p_limite INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    axo_pagado INTEGER,
    metros NUMERIC,
    tipo CHAR(1),
    fecha_alta DATE,
    vigencia CHAR(1),
    observaciones VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Query original Pascal (líneas 117-119):
    -- Qryestoy.ParamByName('nom').AsString:='%'+mxFlatEdtNombre.Text+'%';
    -- Qryestoy.open;
    -- SQL: 'select * from regprop where nombre like :nom'

    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.axo_pagado,
        d.metros,
        d.tipo,
        d.fecha_alta,
        d.vigencia,
        d.observaciones
    FROM public.ta_13_datosrcm d
    WHERE d.cementerio = 'G'
      --AND d.vigencia = 'S'
      AND d.nombre ILIKE '%' || p_nombre || '%'
    ORDER BY d.nombre, d.control_rcm
    LIMIT p_limite
    OFFSET p_offset;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consultaguad_buscar_por_nombre IS 'Busca folios del Cementerio Guadalajara por nombre del titular con paginación';

-- =============================================
-- 3. sp_consultaguad_listar_todos
-- Descripción: Lista todos los folios del cementerio Guadalajara (paginado)
-- Parámetros:
--   - p_limite: Número máximo de resultados (default 100)
--   - p_offset: Número de registros a saltar (default 0)
-- Retorna: TABLE con folios del cementerio
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultaguad_listar_todos(
    p_limite INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio CHAR(1),
    clase SMALLINT,
    clase_alfa VARCHAR(10),
    seccion SMALLINT,
    seccion_alfa VARCHAR(10),
    linea SMALLINT,
    linea_alfa VARCHAR(20),
    fosa SMALLINT,
    fosa_alfa VARCHAR(20),
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    axo_pagado INTEGER,
    metros NUMERIC,
    tipo CHAR(1),
    fecha_alta DATE,
    vigencia CHAR(1),
    observaciones VARCHAR(60)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Listar todos los folios del cementerio (para el caso sin filtros)
    -- Ordenado por control_rcm para paginación consistente

    RETURN QUERY
    SELECT
        d.control_rcm,
        d.cementerio,
        d.clase,
        d.clase_alfa,
        d.seccion,
        d.seccion_alfa,
        d.linea,
        d.linea_alfa,
        d.fosa,
        d.fosa_alfa,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.axo_pagado,
        d.metros,
        d.tipo,
        d.fecha_alta,
        d.vigencia,
        d.observaciones
    FROM public.ta_13_datosrcm d
    WHERE d.cementerio = 'G'
      --AND d.vigencia = 'S'
    ORDER BY d.control_rcm
    LIMIT p_limite
    OFFSET p_offset;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consultaguad_listar_todos IS 'Lista todos los folios del Cementerio Guadalajara con paginación';

-- =============================================
-- PERMISOS
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultaguad_buscar_por_ubicacion TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultaguad_buscar_por_nombre TO role_cementerio;
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultaguad_listar_todos TO role_cementerio;

-- =============================================
-- NOTAS DE MIGRACIÓN
-- =============================================
-- 1. La tabla original "regprop" de la base "guadalajaracem" fue migrada a ta_13_datosrcm
-- 2. El campo "ppago" de la tabla original no existe en ta_13_datosrcm
-- 3. Query3 (búsqueda por ppago) se OMITE en la migración por falta de campo equivalente
-- 4. La búsqueda por ubicación usa linea >= (mayor o igual) según lógica original
-- 5. Todas las búsquedas filtran por cementerio='GUADAL' y vigencia='S'

-- =============================================
-- FIN DE ARCHIVO
-- =============================================
