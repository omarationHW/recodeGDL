-- =============================================
-- SP: sp_reporte_general_mercados
-- Descripción: Reporte general con estadísticas de locales, pagos y adeudos por mercado
-- Componente: ReporteGeneralMercados.vue
-- Base: mercados.public
-- Fecha: 2025-12-05
-- CORREGIDO: Eliminadas referencias cross-database, usando solo schema.table
-- =============================================

DROP FUNCTION IF EXISTS public.sp_reporte_general_mercados(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_reporte_general_mercados(
    p_oficina INTEGER,
    p_axo INTEGER,
    p_periodo INTEGER
)
RETURNS TABLE(
    oficina SMALLINT,
    num_mercado SMALLINT,
    descripcion VARCHAR,
    total_locales BIGINT,
    locales_con_pagos BIGINT,
    locales_con_adeudos BIGINT,
    total_pagos_periodo BIGINT,
    importe_pagos NUMERIC(14,2),
    total_adeudos_periodo BIGINT,
    importe_adeudos NUMERIC(14,2),
    porcentaje_cobranza NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH mercados_locales AS (
        SELECT
            l.oficina,
            l.num_mercado,
            m.descripcion,
            COUNT(l.id_local) as total_locales
        FROM
            publico.ta_11_locales l
        INNER JOIN
            publico.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado AND m.oficina = l.oficina
        WHERE
            l.oficina = p_oficina
            AND l.vigencia = 'A'
        GROUP BY
            l.oficina, l.num_mercado, m.descripcion
    ),
    pagos_mercados AS (
        SELECT
            l.oficina,
            l.num_mercado,
            COUNT(DISTINCT l.id_local) as locales_con_pagos,
            COUNT(p.id_pago_local) as total_pagos_periodo,
            COALESCE(SUM(p.importe_pago), 0) as importe_pagos
        FROM
            publico.ta_11_pagos_local p
        INNER JOIN
            publico.ta_11_locales l ON l.id_local = p.id_local
        WHERE
            l.oficina = p_oficina
            AND p.axo = p_axo
            AND p.periodo = p_periodo
        GROUP BY
            l.oficina, l.num_mercado
    ),
    adeudos_mercados AS (
        SELECT
            l.oficina,
            l.num_mercado,
            COUNT(DISTINCT l.id_local) as locales_con_adeudos,
            COUNT(a.id_adeudo_local) as total_adeudos_periodo,
            COALESCE(SUM(a.importe), 0) as importe_adeudos
        FROM
            publico.ta_11_adeudo_local a
        INNER JOIN
            publico.ta_11_locales l ON l.id_local = a.id_local
        WHERE
            l.oficina = p_oficina
            AND a.axo = p_axo
            AND a.periodo = p_periodo
        GROUP BY
            l.oficina, l.num_mercado
    )
    SELECT
        ml.oficina,
        ml.num_mercado,
        ml.descripcion,
        ml.total_locales,
        COALESCE(pm.locales_con_pagos, 0) as locales_con_pagos,
        COALESCE(am.locales_con_adeudos, 0) as locales_con_adeudos,
        COALESCE(pm.total_pagos_periodo, 0) as total_pagos_periodo,
        COALESCE(pm.importe_pagos, 0)::NUMERIC(14,2) as importe_pagos,
        COALESCE(am.total_adeudos_periodo, 0) as total_adeudos_periodo,
        COALESCE(am.importe_adeudos, 0)::NUMERIC(14,2) as importe_adeudos,
        CASE
            WHEN ml.total_locales > 0 THEN
                (COALESCE(pm.locales_con_pagos, 0)::NUMERIC / ml.total_locales::NUMERIC * 100)
            ELSE 0
        END::NUMERIC(5,2) as porcentaje_cobranza
    FROM
        mercados_locales ml
    LEFT JOIN
        pagos_mercados pm ON pm.oficina = ml.oficina AND pm.num_mercado = ml.num_mercado
    LEFT JOIN
        adeudos_mercados am ON am.oficina = ml.oficina AND am.num_mercado = ml.num_mercado
    ORDER BY
        ml.num_mercado;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_reporte_general_mercados(INTEGER, INTEGER, INTEGER) IS
'Genera reporte general con estadísticas completas por mercado.
Parámetros: p_oficina (recaudadora), p_axo (año), p_periodo (mes).
Retorna: totales de locales, pagos, adeudos y porcentaje de cobranza por mercado.
NOTA: JOIN corregido usando num_mercado_nvo (no num_mercado) en ta_11_mercados.';
