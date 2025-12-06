-- ==============================================================================
-- STORED PROCEDURE: sp_get_pagos_loc_grl
-- Base de Datos: mercados
-- Esquema: public
-- Descripción: Obtiene el reporte de pagos realizados por local en un mercado
--              específico dentro de un rango de fechas.
--              Incluye información de requerimientos y periodos pagados.
--
-- Parámetros:
--   p_mercado     INTEGER - Número del mercado
--   p_fecha_desde DATE    - Fecha inicio del rango de búsqueda
--   p_fecha_hasta DATE    - Fecha fin del rango de búsqueda
--
-- Retorna: Conjunto de registros con información de pagos por local
-- ==============================================================================

DROP FUNCTION IF EXISTS public.sp_get_pagos_loc_grl(INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION public.sp_get_pagos_loc_grl(
    p_mercado INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    id_local INTEGER,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local VARCHAR(3),
    bloque VARCHAR(2),
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    folio CHAR(30),
    fecha_modificacion TEXT,
    usuario VARCHAR(10),
    fecha_emision DATE,
    folio_1 INTEGER,
    id_control INTEGER,
    requerimientos TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH pagos_base AS (
        SELECT
            a.id_local,
            a.num_mercado,
            a.categoria,
            a.seccion,
            a.local,
            a.letra_local,
            a.bloque,
            b.axo,
            b.periodo,
            b.fecha_pago,
            b.oficina_pago,
            b.caja_pago,
            b.operacion_pago,
            b.importe_pago,
            b.folio,
            COALESCE(b.fecha_modificacion::TEXT, '') as fecha_modificacion,
            COALESCE(b.id_usuario::VARCHAR(10), '') as usuario,
            d.fecha_emision,
            d.folio as folio_1,
            d.id_control
        FROM publico.ta_11_locales a
        INNER JOIN publico.ta_11_pagos_local b ON b.id_local = a.id_local
        LEFT OUTER JOIN publico.ta_15_apremios d ON
            d.modulo = 11
            AND d.control_otr = b.id_local
            AND d.vigencia = '2'
            AND d.fecha_pago = b.fecha_pago
            AND d.recaudadora = b.oficina_pago
            AND d.caja = b.caja_pago
            AND d.operacion = b.operacion_pago
        WHERE a.num_mercado = p_mercado
          AND b.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    ),
    periodos_agrupados AS (
        SELECT
            pb.id_control,
            string_agg(
                DISTINCT per.ayo::TEXT || '-' || per.periodo::TEXT,
                ','
                ORDER BY per.ayo::TEXT || '-' || per.periodo::TEXT
            ) as periodos_req
        FROM pagos_base pb
        INNER JOIN publico.ta_15_periodos per ON per.control_otr = pb.id_control
        WHERE pb.id_control IS NOT NULL
        GROUP BY pb.id_control
    )
    SELECT
        pb.id_local,
        pb.num_mercado,
        pb.categoria,
        pb.seccion,
        pb.local,
        pb.letra_local,
        pb.bloque,
        pb.axo,
        pb.periodo,
        pb.fecha_pago,
        pb.oficina_pago,
        pb.caja_pago,
        pb.operacion_pago,
        pb.importe_pago,
        pb.folio,
        pb.fecha_modificacion,
        pb.usuario,
        pb.fecha_emision,
        pb.folio_1,
        pb.id_control,
        COALESCE(pa.periodos_req, '') as requerimientos
    FROM pagos_base pb
    LEFT JOIN periodos_agrupados pa ON pa.id_control = pb.id_control
    ORDER BY
        pb.seccion,
        pb.local,
        pb.letra_local,
        pb.bloque,
        pb.fecha_pago,
        pb.axo,
        pb.periodo,
        pb.fecha_emision,
        pb.folio_1;
END;
$$;

-- Comentarios para documentación
COMMENT ON FUNCTION public.sp_get_pagos_loc_grl(INTEGER, DATE, DATE) IS
'Reporte de pagos realizados por local en un mercado específico. Incluye información de requerimientos y periodos pagados.';
