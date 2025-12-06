-- =============================================
-- SP: sp_rpt_pagos_caja
-- Descripción: Reporte de pagos agrupados por caja recaudadora
-- Componente: RptPagosCaja.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_pagos_caja(INTEGER, DATE, DATE, VARCHAR);

CREATE OR REPLACE FUNCTION public.sp_rpt_pagos_caja(
    p_oficina INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_caja VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    num_mercado SMALLINT,
    descripcion VARCHAR,
    total_pagos BIGINT,
    importe_total NUMERIC(14,2),
    fecha_inicio DATE,
    fecha_fin DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.oficina_pago::SMALLINT,
        p.caja_pago::VARCHAR,
        l.num_mercado::SMALLINT,
        m.descripcion::VARCHAR,
        COUNT(p.id_pago_local)::BIGINT as total_pagos,
        COALESCE(SUM(p.importe_pago), 0)::NUMERIC(14,2) as importe_total,
        MIN(p.fecha_pago)::DATE as fecha_inicio,
        MAX(p.fecha_pago)::DATE as fecha_fin
    FROM
        publico.ta_11_pagos_local p
    INNER JOIN
        publico.ta_11_locales l ON l.id_local = p.id_local
    INNER JOIN
        publico.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado AND m.oficina = l.oficina
    WHERE
        p.oficina_pago = p_oficina
        AND p.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
        AND (p_caja IS NULL OR p.caja_pago = p_caja)
    GROUP BY
        p.oficina_pago, p.caja_pago, l.num_mercado, m.descripcion
    ORDER BY
        p.caja_pago, l.num_mercado;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION publico.sp_rpt_pagos_caja(INTEGER, DATE, DATE, VARCHAR) IS
'Genera reporte de pagos agrupados por caja recaudadora.
Parámetros: p_oficina (recaudadora), p_fecha_desde, p_fecha_hasta, p_caja (opcional).
Retorna: totales de pagos e importe por caja y mercado en el rango de fechas.';
