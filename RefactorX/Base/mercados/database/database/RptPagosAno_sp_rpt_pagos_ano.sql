-- =============================================
-- SP: sp_rpt_pagos_ano
-- Descripción: Reporte de pagos agrupados por año
-- Componente: RptPagosAno.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_pagos_ano(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_pagos_ano(
    p_oficina INTEGER,
    p_axo INTEGER DEFAULT NULL,
    p_mercado INTEGER DEFAULT NULL
)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado SMALLINT,
    descripcion VARCHAR,
    axo SMALLINT,
    total_locales BIGINT,
    total_pagos BIGINT,
    importe_total NUMERIC(14,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.oficina,
        l.num_mercado,
        m.descripcion,
        p.axo,
        COUNT(DISTINCT l.id_local) as total_locales,
        COUNT(p.id_pago_local) as total_pagos,
        COALESCE(SUM(p.importe_pago), 0)::NUMERIC(14,2) as importe_total
    FROM
        publico.ta_11_pagos_local p
    INNER JOIN
        publico.ta_11_locales l ON l.id_local = p.id_local
    INNER JOIN
        publico.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado AND m.oficina = l.oficina
    WHERE
        l.oficina = p_oficina
        AND (p_axo IS NULL OR p.axo = p_axo)
        AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
    GROUP BY
        l.oficina, l.num_mercado, m.descripcion, p.axo
    ORDER BY
        p.axo DESC, l.num_mercado;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_rpt_pagos_ano(INTEGER, INTEGER, INTEGER) IS
'Genera reporte de pagos agrupados por año y mercado.
Parámetros: p_oficina (recaudadora), p_axo (año opcional), p_mercado (opcional).
Retorna: totales de locales, pagos e importe por mercado y año.';
