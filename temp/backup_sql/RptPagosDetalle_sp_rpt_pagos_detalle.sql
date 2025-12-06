-- =============================================
-- SP: sp_rpt_pagos_detalle
-- Descripción: Reporte detallado de pagos con información de transacción
-- Componente: RptPagosDetalle.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_pagos_detalle(INTEGER, INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION public.sp_rpt_pagos_detalle(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    fecha_pago TIMESTAMP,
    folio VARCHAR,
    categoria INTEGER,
    seccion INTEGER,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    axo INTEGER,
    periodo INTEGER,
    caja_pago VARCHAR,
    operacion_pago VARCHAR,
    importe_pago NUMERIC(12,2),
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pl.fecha_pago::TIMESTAMP,
        pl.folio_pago::VARCHAR as folio,
        l.categoria::INTEGER,
        l.seccion::INTEGER,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        pl.axo::INTEGER,
        pl.periodo::INTEGER,
        COALESCE(pl.caja_pago::TEXT, 'N/A')::VARCHAR as caja_pago,
        COALESCE(pl.operacion_pago::TEXT, 'N/A')::VARCHAR as operacion_pago,
        pl.importe_pago::NUMERIC(12,2),
        COALESCE(u.nombre, 'N/A')::VARCHAR as usuario
    FROM
        padron_licencias.comun.ta_11_pagos_local pl
    INNER JOIN
        padron_licencias.comun.ta_11_locales l ON l.id_local = pl.id_local
    LEFT JOIN
        padron_licencias.public.usuarios u ON u.id_usuario = pl.id_usuario
    WHERE
        l.oficina = p_oficina
        AND l.mercado = p_mercado
        AND pl.fecha_pago IS NOT NULL
        AND pl.fecha_pago::DATE BETWEEN p_fecha_desde AND p_fecha_hasta
    ORDER BY
        pl.fecha_pago DESC, l.local;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_rpt_pagos_detalle(INTEGER, INTEGER, DATE, DATE) IS
'Genera reporte detallado de pagos con información completa de transacción.
Parámetros: p_oficina (recaudadora), p_mercado, p_fecha_desde, p_fecha_hasta.
Retorna: información detallada del pago incluyendo folio, caja, operación y usuario.';
