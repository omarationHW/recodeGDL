-- =============================================
-- MÓDULO: Consulta RCM por Ubicación de Cementerios
-- ARCHIVO: 08_SP_CEMENTERIOS_CONSULTARCM_EXACTO_all_procedures.sql
-- DESCRIPCIÓN: SPs para búsqueda de folios por ubicación física (cementerio, clase, sección, línea, fosa)
-- FECHA: 2025-11-25
-- ESQUEMAS SEGÚN postgreok.csv:
--   - ta_13_datosrcm → padron_licencias.comun
--   - tc_13_cementerios → cementerio.public
-- =============================================

-- =============================================
-- SP 1: sp_consultarcm_buscar_por_ubicacion
-- Busca folio por ubicación física completa
-- Origen: ConsultaRCM.pas línea 393-401, ConsultaRCM.dfm línea 2147
-- Query original: SELECT * FROM ta_13_datosrcm WHERE cementerio=:cem AND clase=:clasec
--                 AND clase_alfa=:claseal AND seccion=:secc AND seccion_alfa=:seccional
--                 AND linea=:lineac AND linea_alfa=:lineaal AND fosa=:fosac AND fosa_alfa=:fosaal
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultarcm_buscar_por_ubicacion(
    p_cementerio CHAR(1),
    p_clase SMALLINT,
    p_clase_alfa VARCHAR(10),
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR(10),
    p_linea SMALLINT,
    p_linea_alfa VARCHAR(20),
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR(20)
)
RETURNS TABLE(
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
    observaciones VARCHAR(60),
    usuario INTEGER,
    fecha_mov DATE,
    tipo CHAR(1),
    vigencia CHAR(1)
) AS $$
BEGIN
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
        d.observaciones,
        d.usuario,
        d.fecha_mov,
        d.tipo,
        d.vigencia
    FROM public.ta_13_datosrcm d
    WHERE d.cementerio = p_cementerio
      AND d.clase = p_clase
      AND d.clase_alfa = p_clase_alfa
      AND d.seccion = p_seccion
      AND d.seccion_alfa = p_seccion_alfa
      AND d.linea = p_linea
      AND d.linea_alfa = p_linea_alfa
      AND d.fosa = p_fosa
      AND d.fosa_alfa = p_fosa_alfa
      AND d.vigencia = 'A';
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- SP 2: sp_consultarcm_listar_cementerios
-- Lista cementerios activos
-- Origen: Usado en formulario para dropdown de cementerios
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_consultarcm_listar_cementerios()
RETURNS TABLE(
    cementerio CHAR(1),
    nombre VARCHAR(60),
    domicilio VARCHAR(60)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre,
        c.domicilio
    FROM public.tc_13_cementerios c
    ORDER BY c.cementerio;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- COMENTARIOS Y NOTAS:
-- 1. Usa esquemas correctos según postgreok.csv:
--    - ta_13_datosrcm → padron_licencias.comun
--    - tc_13_cementerios → cementerio.public
-- 2. Búsqueda por ubicación física completa (8 parámetros)
-- 3. Solo registros activos (vigencia = 'A')
-- 4. Validaciones de rango en el front (clase: 1-3)
-- =============================================
