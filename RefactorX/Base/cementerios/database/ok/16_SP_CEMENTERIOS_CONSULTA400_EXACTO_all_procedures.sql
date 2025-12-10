-- =============================================
-- CONSULTA400.VUE - STORED PROCEDURES
-- =============================================
-- Descripción: SPs para consulta especial RCM 400 (JOIN fosas + pagos)
-- Componente Vue: Consulta400.vue
-- Pascal Original: consulta400.pas
-- Fecha Creación: 2025-11-27
--
-- TABLAS INVOLUCRADAS:
--   - padron_licencias.comun.ta_13_datosrcm (cmf01dcem) - Datos de fosas
--   - cementerio.public.ta_13_pagosrcm (cmf01pcem) - Pagos de mantenimiento
--   - cementerio.public.tc_13_cementerios - Catálogo de cementerios
--
-- SCHEMAS SEGÚN postgreok.csv:
--   ta_13_datosrcm → padron_licencias.comun
--   ta_13_pagosrcm → cementerio.public
--   tc_13_cementerios → cementerio.public
-- =============================================

-- =============================================
-- 1. sp_consulta400_listar_cementerios
-- Descripción: Lista todos los cementerios disponibles
-- Retorna: TABLE con cementerios
-- =============================================
-- ***** PARA MEJORAR EL PERFORMANCE SE MANDA A LLAMAR sp_get_cementerios_list  *******

CREATE OR REPLACE FUNCTION public.sp_consulta400_listar_cementerios()
RETURNS TABLE (
    cementerio CHAR(1),
    nombre_cementerio VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (consulta400.dfm líneas 1442-1443):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from tc_13_cementerios'
    */

    RETURN QUERY
    SELECT
        c.cementerio,
        c.nombre_cementerio
    FROM public.tc_13_cementerios c
    ORDER BY c.cementerio;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consulta400_listar_cementerios IS 'Lista todos los cementerios para dropdown';

-- =============================================
-- 2. sp_consulta400_buscar_por_ubicacion
-- Descripción: Búsqueda avanzada con JOIN entre fosas y pagos
-- Parámetros: 9 parámetros de ubicación completa
-- Retorna: TABLE con JOIN de ta_13_datosrcm + ta_13_pagosrcm
-- =============================================



CREATE OR REPLACE FUNCTION public.sp_consulta400_buscar_por_ubicacion(
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
RETURNS TABLE (
    control_rcm INTEGER,
    cement CHAR(1),
    clase SMALLINT,
    clasal VARCHAR(10),
    secc SMALLINT,
    seccal VARCHAR(10),
    linea SMALLINT,
    lineal VARCHAR(20),
    fosa SMALLINT,
    fosaal VARCHAR(20),
    ppag INTEGER,
    pmetr NUMERIC,
    nomb VARCHAR(60),
    domi VARCHAR(60),
    exte CHAR(6),
    inte CHAR(6),
    colon VARCHAR(30),
    control_id INTEGER,
    cementp CHAR(1),
    clasep SMALLINT,
    clasalp VARCHAR(10),
    seccp SMALLINT,
    seccalp VARCHAR(10),
    lineap SMALLINT,
    linealp VARCHAR(20),
    fosap SMALLINT,
    fosaalp VARCHAR(20),
    fecing DATE,
    recing INTEGER,
    cajing CHAR(3),
    ppagd INTEGER,
    ppagh INTEGER,
    imppag NUMERIC(16,2),
    imprec NUMERIC(16,2),
    vigencia CHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_rcm,
        a.cementerio AS cement,
        a.clase,
        a.clase_alfa AS clasal,
        a.seccion AS secc,
        a.seccion_alfa AS seccal,
        a.linea,
        a.linea_alfa AS lineal,
        a.fosa,
        a.fosa_alfa AS fosaal,
        a.axo_pagado AS ppag,
        a.metros AS pmetr,
        a.nombre AS nomb,
        a.domicilio AS domi,
        a.exterior AS exte,
        a.interior AS inte,
        a.colonia AS colon,
        b.control_id,
        b.cementerio AS cementp,
        b.clase AS clasep,
        b.clase_alfa AS clasalp,
        b.seccion AS seccp,
        b.seccion_alfa AS seccalp,
        b.linea AS lineap,
        b.linea_alfa AS linealp,
        b.fosa AS fosap,
        b.fosa_alfa AS fosaalp,
        b.fecing,
        b.recing :: integer,
        b.cajing,
        b.axo_pago_desde::integer AS ppagd,  -- CAST
        b.axo_pago_hasta::integer AS ppagh,  -- CAST
        b.importe_anual AS imppag,
        b.importe_recargos AS imprec,
        b.vigencia
    FROM public.ta_13_datosrcm a
    INNER JOIN public.ta_13_pagosrcm b
        ON a.cementerio = b.cementerio
        AND a.clase = b.clase
        AND COALESCE(a.clase_alfa, '') = COALESCE(b.clase_alfa, '')
        AND a.seccion = b.seccion
        AND COALESCE(a.seccion_alfa, '') = COALESCE(b.seccion_alfa, '')
        AND a.linea = b.linea
        AND COALESCE(a.linea_alfa, '') = COALESCE(b.linea_alfa, '')
        AND a.fosa = b.fosa
        AND COALESCE(a.fosa_alfa, '') = COALESCE(b.fosa_alfa, '')
    WHERE a.cementerio = p_cementerio
        AND a.clase = p_clase
        AND COALESCE(a.clase_alfa, '') = COALESCE(p_clase_alfa, '')
        AND a.seccion = p_seccion
        AND COALESCE(a.seccion_alfa, '') = COALESCE(p_seccion_alfa, '')
        AND a.linea = p_linea
        AND COALESCE(a.linea_alfa, '') = COALESCE(p_linea_alfa, '')
        AND a.fosa = p_fosa
        AND COALESCE(a.fosa_alfa, '') = COALESCE(p_fosa_alfa, '')
    ORDER BY b.fecing DESC;
END;
$$;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_consulta400_buscar_por_ubicacion IS 'JOIN fosas + pagos por ubicación completa (consulta especial RCM 400)';

-- =============================================
-- FIN DE ARCHIVO
-- Total SPs creados: 2
-- =============================================
