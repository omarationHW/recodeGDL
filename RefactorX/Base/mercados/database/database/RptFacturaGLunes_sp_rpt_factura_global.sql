-- =============================================
-- SP: sp_rpt_factura_global
-- Descripción: Reporte de facturación global por mercado
-- Componente: RptFacturaGLunes.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_factura_global(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_factura_global(
    p_oficina INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER
)
RETURNS TABLE(
    num_mercado INTEGER,
    descripcion VARCHAR,
    total_facturado NUMERIC(12,2),
    total_locales INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.num_mercado_nvo::INTEGER as num_mercado,
        m.descripcion::VARCHAR as descripcion,
        COALESCE(SUM(pl.importe_pago), 0)::NUMERIC(12,2) as total_facturado,
        COUNT(DISTINCT l.id_local)::INTEGER as total_locales
    FROM
        publico.ta_11_mercados m
    LEFT JOIN
        publico.ta_11_locales l ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN
        publico.ta_11_pagos_local pl ON pl.id_local = l.id_local
            AND pl.axo = p_axo
            AND pl.periodo = p_periodo
            AND pl.fecha_pago IS NOT NULL
    WHERE
        m.oficina = p_oficina
    GROUP BY
        m.num_mercado_nvo, m.descripcion
    ORDER BY
        m.num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_rpt_factura_global(INTEGER, INTEGER, INTEGER) IS
'Genera reporte de facturación global agrupado por mercado.
Parámetros: p_oficina (recaudadora), p_axo (año), p_periodo (mes).
Retorna: número de mercado, descripción, total facturado y cantidad de locales.';
