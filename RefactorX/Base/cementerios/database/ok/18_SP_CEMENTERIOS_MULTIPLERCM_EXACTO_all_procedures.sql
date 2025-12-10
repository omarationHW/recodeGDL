-- =============================================
-- MULTIPLERCM.VUE - STORED PROCEDURES
-- =============================================
-- Descripción: SPs para búsqueda múltiple de folios por ubicación física (RCM) con paginación
-- Componente Vue: MultipleRCM.vue
-- Pascal Original: MultipleRCM.pas
-- Fecha Creación: 2025-11-27
--
-- TABLAS INVOLUCRADAS:
--   - padron_licencias.comun.ta_13_datosrcm (datos de fosas/folios)
--   - cementerio.public.tc_13_cementerios (catálogo de cementerios)
--
-- SCHEMAS SEGÚN postgreok.csv:
--   ta_13_datosrcm → padron_licencias.comun
--   tc_13_cementerios → cementerio.public
-- =============================================

-- =============================================
-- 1. sp_multiplercm_listar_cementerios
-- Descripción: Lista todos los cementerios para dropdown
-- Retorna: TABLE con cementerios ordenados
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_multiplercm_listar_cementerios()
RETURNS TABLE (
    cementerio CHAR(1),
    nombre_cementerio VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (MultipleRCM.pas línea 128):
    -- qrycem.open; (select * from tc_13_cementerios)
    */

    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre_cementerio
    FROM cementerio.public.tc_13_cementerios c
    ORDER BY c.cementerio;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_multiplercm_listar_cementerios IS 'Lista cementerios para dropdown (MultipleRCM)';

-- =============================================
-- 2. sp_multiplercm_buscar_por_ubicacion
-- Descripción: Búsqueda de folios por ubicación física con filtros >= y paginación
-- Parámetros:
--   - p_cementerio: Código del cementerio
--   - p_clase, p_clase_alfa: Clase >= valor (numérico + alfabético)
--   - p_seccion, p_seccion_alfa: Sección >= valor
--   - p_linea, p_linea_alfa: Línea >= valor
--   - p_fosa, p_fosa_alfa: Fosa >= valor
--   - p_ultimo_folio: Control_rcm del último registro (0 para primera página)
--   - p_limite: Cantidad de registros (100 en Pascal original)
-- Retorna: TABLE con folios encontrados ordenados por ubicación
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_multiplercm_buscar_por_ubicacion(
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20),
    p_ultimo_folio INTEGER,
    p_limite INTEGER
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
    axo_pagado INTEGER,
    metros NUMERIC,
    nombre VARCHAR(60),
    domicilio VARCHAR(60),
    exterior CHAR(6),
    interior CHAR(6),
    colonia VARCHAR(30),
    codigo_postal VARCHAR(10),
    rfc VARCHAR(13),
    curp VARCHAR(18),
    telefono VARCHAR(20),
    email VARCHAR(100),
    observaciones VARCHAR(60),
    fecha_alta DATE,
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (MultipleRCM.pas):
    -- Búsqueda inicial (líneas 94-105):
    -- SQL: 'select first 100 * from ta_13_datosrcm where
    --       cementerio=:cem
    --       and clase>=:clase
    --       and seccion>=:seccion
    --       and linea>=:linea
    --       and fosa>=:fosa
    --       and control_rcm>0 order by clase,seccion,linea,fosa'
    --
    -- "Cargar Más" (líneas 173-182):
    -- SQL: 'select first 100 * from ta_13_datosrcm where
    --       cementerio=:cem
    --       and clase>=:clase and clase_alfa>=:clase_alfa
    --       and seccion>=:seccion and seccion_alfa>=:seccion_alfa
    --       and linea>=:linea and linea_alfa>=:linea_alfa
    --       and (fosa>=:fosa and fosa<=:fosa+100) and fosa_alfa>=:fosa_alfa
    --       and control_rcm>:folio'
    -- Nota: Paginación usa última ubicación (líneas 162-169)
    */

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
        d.axo_pagado,
        d.metros,
        d.nombre,
        d.domicilio,
        d.exterior,
        d.interior,
        d.colonia,
        d.codigo_postal,
        d.rfc,
        d.curp,
        d.telefono,
        d.email,
        d.observaciones,
        d.fecha_alta,
        d.vigencia
    FROM public.ta_13_datosrcm d
    WHERE d.cementerio = p_cementerio
        AND d.clase >= p_clase
        AND (p_clase_alfa IS NULL OR p_clase_alfa = '' OR COALESCE(d.clase_alfa, '') >= p_clase_alfa)
        AND d.seccion >= p_seccion
        AND (p_seccion_alfa IS NULL OR p_seccion_alfa = '' OR COALESCE(d.seccion_alfa, '') >= p_seccion_alfa)
        AND d.linea >= p_linea
        AND (p_linea_alfa IS NULL OR p_linea_alfa = '' OR COALESCE(d.linea_alfa, '') >= p_linea_alfa)
        AND d.fosa >= p_fosa
        AND d.fosa <= (p_fosa + 100) -- Rango de fosas (línea 181 Pascal)
        AND (p_fosa_alfa IS NULL OR p_fosa_alfa = '' OR COALESCE(d.fosa_alfa, '') >= p_fosa_alfa)
        AND d.control_rcm > p_ultimo_folio
    ORDER BY d.clase, d.seccion, d.linea, d.fosa
    LIMIT p_limite;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_multiplercm_buscar_por_ubicacion IS 'Búsqueda paginada de folios por ubicación física con filtros >= (MultipleRCM)';

-- =============================================
-- FIN DE ARCHIVO
-- Total SPs creados: 2
-- =============================================
