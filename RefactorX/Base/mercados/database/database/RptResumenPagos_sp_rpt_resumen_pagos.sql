-- =============================================
-- SP: sp_rpt_resumen_pagos
-- Descripción: Resumen consolidado de pagos por mercado
-- Componente: RptResumenPagos.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_resumen_pagos(INTEGER, DATE, DATE, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_resumen_pagos(
    p_oficina INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_mercado INTEGER DEFAULT NULL
)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado SMALLINT,
    descripcion VARCHAR(30),
    total_locales_con_pago BIGINT,
    total_pagos BIGINT,
    total_periodos_pagados BIGINT,
    importe_total NUMERIC,
    pago_promedio NUMERIC,
    fecha_primer_pago DATE,
    fecha_ultimo_pago DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.oficina,
        l.num_mercado,
        m.descripcion,
        COUNT(DISTINCT l.id_local) as total_locales_con_pago,
        COUNT(p.id_pago_local) as total_pagos,
        COUNT(DISTINCT (p.axo || '-' || p.periodo)) as total_periodos_pagados,
        COALESCE(SUM(p.importe_pago), 0) as importe_total,
        COALESCE(AVG(p.importe_pago), 0) as pago_promedio,
        MIN(p.fecha_pago) as fecha_primer_pago,
        MAX(p.fecha_pago) as fecha_ultimo_pago
    FROM
        publico.ta_11_pagos_local p
    INNER JOIN
        publico.ta_11_locales l ON l.id_local = p.id_local
    INNER JOIN
        publico.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado
    WHERE
        l.oficina = p_oficina
        AND p.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
        AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
    GROUP BY
        l.oficina, l.num_mercado, m.descripcion
    ORDER BY
        l.num_mercado;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_rpt_resumen_pagos(INTEGER, DATE, DATE, INTEGER) IS
'Genera resumen consolidado de pagos por mercado.
Parámetros: p_oficina (recaudadora), p_fecha_desde, p_fecha_hasta, p_mercado (opcional).
Retorna: totales, promedios y estadísticas de pagos por mercado.';
