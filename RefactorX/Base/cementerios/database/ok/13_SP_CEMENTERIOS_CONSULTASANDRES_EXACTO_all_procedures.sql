-- =============================================
-- CEMENTERIOS - CONSULTA CEMENTERIO SAN ANDRÉS (ConsultaSAndres.vue)
-- =============================================
-- Archivo: 13_SP_CEMENTERIOS_CONSULTASANDRES_EXACTO_all_procedures.sql
-- Descripción: Stored Procedure para consulta simple del Cementerio San Andrés
-- Fecha: 2025-11-25
--
-- ESQUEMAS según postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - tc_13_cementerios → cementerio.public
--
-- LÓGICA ORIGINAL (Pascal):
--   - Base de datos: sanandres (tabla: datos)
--   - Query simple: SELECT * FROM datos
--   - Sin filtros, sin búsquedas
--   - Solo lectura de TODOS los registros del cementerio
--
-- MIGRACIÓN A POSTGRESQL:
--   - La tabla datos → ta_13_datosrcm (con filtro cementerio='SANDRES')
--   - Sin parámetros de búsqueda
--   - Lista paginada simple con LIMIT/OFFSET
--
-- SPS CREADOS:
--   1. sp_consultasandres_listar_todos(p_limite, p_offset) → Lista todos los folios
-- =============================================

-- =============================================
-- 1. sp_consultasandres_listar_todos
-- Descripción: Lista todos los folios del cementerio San Andrés (paginado)
--              Réplica exacta del Pascal: SELECT * FROM datos
-- Parámetros:
--   - p_limite: Número máximo de resultados (default 100)
--   - p_offset: Número de registros a saltar (default 0)
-- Retorna: TABLE con folios del cementerio
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultasandres_listar_todos(
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
    -- Query original Pascal (ConsultaSAndres.pas línea 54-59, .dfm línea 172-173):
    -- SQL: 'select * from datos'
    -- Sin filtros, sin parámetros, solo lista todos los registros

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
    WHERE d.cementerio = 'V'
      --AND d.vigencia = 'S'
    ORDER BY d.control_rcm
    LIMIT p_limite
    OFFSET p_offset;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consultasandres_listar_todos IS 'Lista todos los folios del Cementerio San Andrés con paginación (réplica exacta Pascal: SELECT * FROM datos)';

-- =============================================
-- PERMISOS
-- =============================================
-- GRANT EXECUTE ON FUNCTION cementerio.sp_consultasandres_listar_todos TO role_cementerio;

-- =============================================
-- NOTAS DE MIGRACIÓN
-- =============================================
-- 1. La tabla original "datos" fue migrada a ta_13_datosrcm
-- 2. El Pascal NO tiene búsquedas ni filtros - solo muestra TODOS los registros
-- 3. Este cementerio es diferente a los demás (Guadal/Jardin/Mezq):
--    - No tiene búsqueda por ubicación RCM
--    - No tiene búsqueda por nombre
--    - No tiene búsqueda por ppago
--    - Solo es una consulta de lectura simple
-- 4. Se añade paginación (LIMIT/OFFSET) para optimización en PostgreSQL
-- 5. Filtro cementerio='SANDRES' según código del Vue original (línea 130)

-- =============================================
-- FIN DE ARCHIVO
-- =============================================
