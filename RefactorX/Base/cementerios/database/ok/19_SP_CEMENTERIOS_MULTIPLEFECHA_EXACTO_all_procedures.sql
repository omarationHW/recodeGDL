-- =============================================
-- MULTIPLEFECHA.VUE - STORED PROCEDURES
-- =============================================
-- Descripción: SPs para búsqueda de pagos/títulos por fecha
-- Componente Vue: Multiplefecha.vue
-- Pascal Original: Multiplefecha.pas
-- Fecha Creación: 2025-11-28
--
-- TABLAS INVOLUCRADAS:
--   - cementerio.public.ta_13_pagosrcm (pagos de mantenimiento)
--   - cementerio.public.ta_13_titulos (títulos/pagos adicionales)
--
-- SCHEMAS SEGÚN postgreok.csv:
--   ta_13_pagosrcm → cementerio.public
--   ta_13_titulos → cementerio.public
-- =============================================

-- =============================================
-- 1. sp_multiplefecha_buscar_por_fecha
-- Descripción: Búsqueda UNION de pagos y títulos por fecha/recibo/caja
-- Parámetros:
--   - p_fecha: Fecha exacta de búsqueda
--   - p_recibo: Número de recibo >= (1 por defecto)
--   - p_caja: Letra de caja >= ('A' por defecto)
-- Retorna: TABLE con UNION de ta_13_pagosrcm y ta_13_titulos ordenados
-- =============================================
CREATE OR REPLACE FUNCTION public.sp_multiplefecha_buscar_por_fecha(
    p_fecha DATE,
    p_recibo INTEGER,
    p_caja CHAR(3)
)
RETURNS TABLE (
    tipopag VARCHAR(6),
    fecing DATE,
    recing INTEGER,
    cajing CHAR(3),
    opcaja INTEGER,
    control_id INTEGER,
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
    axo_pago_desde INTEGER,
    axo_pago_hasta INTEGER,
    importe_anual NUMERIC(16,2),
    importe_recargos NUMERIC(16,2),
    vigencia CHAR(1),
    usuario INTEGER,
    fecha_mov DATE,
    obser VARCHAR(70)
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* TODO FUTURO: Query SQL original (Multiplefecha.dfm líneas 738-749):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select 'Manten' tipopag,*,' ' obser
    --       from ta_13_pagosrcm where fecing=:fecha and
    --       recing>=:rec and cajing>=:caja
    --       union
    --       SELECT 'Titulo',fecha, id_rec, caja, operacion, 0,control_rcm,
    --              '',0,'',0,'',0,'',0,'', tipo, titulo,   importe, 0,'',0,today,
    --       observaciones
    --           FROM ta_13_titulos  where fecha=:fecha and
    --        id_rec>=:rec and caja>=:caja
    --       order by 2,3,4,5'
    -- Parámetros Pascal (líneas 78-81, 101-105):
    --   :fecha = ExDateTPFecha.Date (fecha seleccionada, default: today)
    --   :rec = FlatSpinEIRec.Value (default: 1)
    --   :caja = FlatECaja.Text (default: 'A')
    -- UNION de dos tablas:
    --   1. ta_13_pagosrcm: Pagos de mantenimiento (tipopag='Manten')
    --   2. ta_13_titulos: Títulos/pagos adicionales (tipopag='Titulo')
    -- ORDER BY: fecing/fecha, recing/id_rec, cajing/caja, opcaja/operacion
    */

    RETURN QUERY
    -- Primera parte del UNION: Pagos de mantenimiento
    SELECT
        'Manten'::VARCHAR(6) AS tipopag,
        p.fecing,
        p.recing,
        p.cajing,
        p.opcaja,
        p.control_id,
        p.control_rcm,
        p.cementerio,
        p.clase,
        p.clase_alfa,
        p.seccion,
        p.seccion_alfa,
        p.linea,
        p.linea_alfa,
        p.fosa,
        p.fosa_alfa,
        p.axo_pago_desde,
        p.axo_pago_hasta,
        p.importe_anual,
        p.importe_recargos,
        p.vigencia,
        p.usuario,
        p.fecha_mov,
        ' '::VARCHAR(70) AS obser
    FROM public.ta_13_pagosrcm p
    WHERE p.fecing = p_fecha
        AND p.recing >= p_recibo
        AND p.cajing >= p_caja

    UNION

    -- Segunda parte del UNION: Títulos
    SELECT
        'Titulo'::VARCHAR(6) AS tipopag,
        t.fecha AS fecing,
        t.id_rec::INTEGER AS recing,
        t.caja::CHAR(3) AS cajing,
        t.operacion AS opcaja,
        0 AS control_id,
        t.control_rcm,
        ''::CHAR(1) AS cementerio,
        0::SMALLINT AS clase,
        ''::VARCHAR(10) AS clase_alfa,
        0::SMALLINT AS seccion,
        ''::VARCHAR(10) AS seccion_alfa,
        0::SMALLINT AS linea,
        ''::VARCHAR(20) AS linea_alfa,
        0::SMALLINT AS fosa,
        ''::VARCHAR(20) AS fosa_alfa,
        t.tipo AS axo_pago_desde,
        t.titulo AS axo_pago_hasta,
        t.importe AS importe_anual,
        0::NUMERIC(16,2) AS importe_recargos,
        ''::CHAR(1) AS vigencia,
        0 AS usuario,
        CURRENT_DATE AS fecha_mov,
        t.observaciones AS obser
    FROM public.ta_13_titulos t
    WHERE t.fecha = p_fecha
        AND t.id_rec >= p_recibo
        AND t.caja >= p_caja

    ORDER BY fecing, recing, cajing, opcaja;

END;
$$;

COMMENT ON FUNCTION cementerio.sp_multiplefecha_buscar_por_fecha IS 'Búsqueda UNION de pagos de mantenimiento y títulos por fecha/recibo/caja (Multiplefecha)';

-- =============================================
-- FIN DE ARCHIVO
-- Total SPs creados: 1
-- =============================================
