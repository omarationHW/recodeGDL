-- =============================================
-- SP: sp_rpt_ingresos_locales
-- Descripción: Reporte de ingresos por renta de locales
-- Componente: RptIngresos.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_ingresos_locales(INTEGER, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_ingresos_locales(
    p_oficina INTEGER,
    p_axo INTEGER,
    p_mercado INTEGER DEFAULT NULL,
    p_periodo INTEGER DEFAULT NULL
)
RETURNS TABLE(
    fecha_pago TIMESTAMP,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    axo INTEGER,
    periodo INTEGER,
    importe_pago NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pl.fecha_pago::TIMESTAMP,
        l.num_mercado::INTEGER as num_mercado,
        l.categoria::INTEGER,
        l.seccion::VARCHAR,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        pl.axo::INTEGER,
        pl.periodo::INTEGER,
        pl.importe_pago::NUMERIC(12,2)
    FROM
        publico.ta_11_pagos_local pl
    INNER JOIN
        publico.ta_11_locales l ON l.id_local = pl.id_local
    WHERE
        l.oficina = p_oficina
        AND pl.axo = p_axo
        AND pl.fecha_pago IS NOT NULL
        AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
        AND (p_periodo IS NULL OR pl.periodo = p_periodo)
    ORDER BY
        pl.fecha_pago DESC, l.num_mercado, l.local;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION publico.sp_rpt_ingresos_locales(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Genera reporte detallado de ingresos por renta de locales.
Parámetros: p_oficina (recaudadora), p_axo (año), p_mercado (opcional), p_periodo (opcional).
Retorna: información de pagos con datos del local y monto.';
