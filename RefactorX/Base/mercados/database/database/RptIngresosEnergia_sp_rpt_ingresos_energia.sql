-- =============================================
-- SP: sp_rpt_ingresos_energia
-- Descripción: Reporte de ingresos por consumo de energía eléctrica
-- Componente: RptIngresosEnergia.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_ingresos_energia(INTEGER, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_ingresos_energia(
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
    consumo NUMERIC(12,2),
    importe_pago NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        pe.fecha_pago::TIMESTAMP,
        l.num_mercado::INTEGER as num_mercado,
        l.categoria::INTEGER,
        l.seccion::VARCHAR,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        pe.axo::INTEGER,
        pe.periodo::INTEGER,
        COALESCE(e.cantidad, 0)::NUMERIC(12,2) as consumo,
        pe.importe_pago::NUMERIC(12,2) as importe_pago
    FROM
        publico.ta_11_pago_energia pe
    INNER JOIN
        publico.ta_11_energia e ON e.id_energia = pe.id_energia
    INNER JOIN
        publico.ta_11_locales l ON l.id_local = e.id_local
    WHERE
        l.oficina = p_oficina
        AND pe.axo = p_axo
        AND pe.fecha_pago IS NOT NULL
        AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
        AND (p_periodo IS NULL OR pe.periodo = p_periodo)
    ORDER BY
        pe.fecha_pago DESC, l.num_mercado, l.local;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION publico.sp_rpt_ingresos_energia(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Genera reporte detallado de ingresos por energía eléctrica.
Parámetros: p_oficina (recaudadora), p_axo (año), p_mercado (opcional), p_periodo (opcional).
Retorna: información de pagos con consumo en kilowatts y monto.';
