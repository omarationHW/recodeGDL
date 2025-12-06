-- =============================================
-- SP: sp_rpt_pagos_grl
-- Descripción: Reporte general de pagos de locales
-- Componente: RptPagosGrl.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_pagos_grl(INTEGER, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_pagos_grl(
    p_oficina INTEGER,
    p_axo INTEGER,
    p_mercado INTEGER DEFAULT NULL,
    p_periodo INTEGER DEFAULT NULL
)
RETURNS TABLE(
    fecha_pago TIMESTAMP,
    oficina INTEGER,
    num_mercado INTEGER,
    categoria INTEGER,
    seccion VARCHAR,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    caja_pago VARCHAR,
    operacion_pago VARCHAR,
    importe_pago NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pl.fecha_pago::TIMESTAMP,
        l.oficina::INTEGER as oficina,
        l.num_mercado::INTEGER as num_mercado,
        l.categoria::INTEGER,
        l.seccion::VARCHAR,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        COALESCE(pl.caja_pago::TEXT, 'N/A')::VARCHAR as caja_pago,
        COALESCE(pl.operacion_pago::TEXT, 'N/A')::VARCHAR as operacion_pago,
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
COMMENT ON FUNCTION publico.sp_rpt_pagos_grl(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Genera reporte general de pagos de locales.
Parámetros: p_oficina (recaudadora), p_axo (año), p_mercado (opcional), p_periodo (opcional).
Retorna: información general de pagos con datos del local y monto.';
