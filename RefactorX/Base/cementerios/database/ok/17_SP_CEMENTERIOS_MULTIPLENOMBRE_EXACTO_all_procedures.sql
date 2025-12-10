-- =============================================
-- MULTIPLENOMBRE.VUE - STORED PROCEDURES
-- =============================================
-- Descripción: SPs para búsqueda múltiple de folios por nombre con paginación
-- Componente Vue: MultipleNombre.vue
-- Pascal Original: MultipleNombre.pas
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
-- 1. sp_multiplenombre_listar_cementerios
-- Descripción: Lista todos los cementerios para dropdown
-- Retorna: TABLE con cementerios ordenados
-- =============================================
CREATE OR REPLACE FUNCTION cementerio.sp_multiplenombre_listar_cementerios()
RETURNS TABLE (
    cementerio CHAR(1),
    nombre_cementerio VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (MultipleNombre.dfm líneas 649-650):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from tc_13_cementerios'
    */

    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre_cementerio
    FROM cementerio.public.tc_13_cementerios c
    ORDER BY c.cementerio;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_multiplenombre_listar_cementerios IS 'Lista cementerios para dropdown (MultipleNombre)';

-- =============================================
-- 2. sp_multiplenombre_buscar_por_nombre
-- Descripción: Búsqueda de folios por nombre con paginación
-- Parámetros:
--   - p_nombre: Patrón LIKE para búsqueda (ya incluye %)
--   - p_cem_inicio: Cementerio inicio del rango (ej: 'A' para todos)
--   - p_cem_fin: Cementerio fin del rango (ej: 'z' para todos, o código específico)
--   - p_ultimo_folio: Control_rcm del último registro (0 para primera página)
--   - p_limite: Cantidad de registros (100 en Pascal original)
-- Retorna: TABLE con folios encontrados ordenados por nombre
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_multiplenombre_buscar_por_nombre(
    p_nombre VARCHAR(60),
    p_cem_inicio CHAR(1),
    p_cem_fin CHAR(1),
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
    /* TODO FUTURO: Query SQL original (MultipleNombre.dfm líneas 706-709):
    -- DatabaseName: cementerio (400, 401, 402, 403)
    -- SQL: 'select first 100 * from ta_13_datosrcm where nombre like :nom
    --       and control_rcm> :cuenta and cementerio between :cem1 and :cem2
    --       order by nombre '
    -- Parámetros Pascal:
    --   :nom = '%' + FlatENombre.Text + '%' (línea 79)
    --   :cuenta = último control_rcm (0 para primera búsqueda, línea 80)
    --   :cem1 y :cem2 = 'A' a 'z' para todos, o cementerio específico (líneas 81-88)
    -- Paginación: líneas 140-164 (botón "Cargar más" usa último control_rcm)
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
    WHERE d.nombre LIKE p_nombre
        AND d.control_rcm > p_ultimo_folio
        AND d.cementerio BETWEEN p_cem_inicio AND p_cem_fin
    ORDER BY d.nombre
    LIMIT p_limite;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_multiplenombre_buscar_por_nombre IS 'Búsqueda paginada de folios por nombre con filtro de cementerio (MultipleNombre)';

-- =============================================
-- FIN DE ARCHIVO
-- Total SPs creados: 2
-- =============================================
