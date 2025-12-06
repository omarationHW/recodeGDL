-- ==============================================================================
-- STORED PROCEDURE: sp_rpt_saldos_locales
-- Base de Datos: mercados
-- Esquema: public
-- Descripción: Reporte de saldos de locales por mercado
--              Muestra el total de adeudos, pagos realizados y saldo pendiente
--              por cada local en un mercado específico
--
-- Parámetros:
--   p_oficina INTEGER - Recaudadora
--   p_mercado INTEGER - Número del mercado
--   p_axo     INTEGER - Año (opcional, si es NULL muestra todos)
--
-- Retorna: Conjunto de registros con información de saldos por local
-- ==============================================================================

DROP FUNCTION IF EXISTS public.sp_rpt_saldos_locales(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_saldos_locales(
    p_oficina INTEGER,
    p_mercado INTEGER,
    p_axo INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id_local INTEGER,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHAR(2),
    local INTEGER,
    letra_local VARCHAR(3),
    bloque VARCHAR(2),
    nombre VARCHAR(60),
    total_adeudos NUMERIC,
    total_pagos NUMERIC,
    saldo NUMERIC,
    ultimo_pago DATE,
    periodos_adeudo BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH adeudos_por_local AS (
        SELECT
            a.id_local,
            SUM(COALESCE(a.importe, 0)) as total_adeudo,
            COUNT(DISTINCT CONCAT(a.axo::TEXT, '-', a.periodo::TEXT)) as periodos
        FROM publico.ta_11_adeudo_local a
        WHERE (p_axo IS NULL OR a.axo = p_axo)
        GROUP BY a.id_local
    ),
    pagos_por_local AS (
        SELECT
            p.id_local,
            SUM(COALESCE(p.importe_pago, 0)) as total_pago,
            MAX(p.fecha_pago) as ultimo_pago_fecha
        FROM publico.ta_11_pagos_local p
        WHERE (p_axo IS NULL OR p.axo = p_axo)
        GROUP BY p.id_local
    )
    SELECT
        l.id_local,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        COALESCE(l.nombre, 'SIN NOMBRE') as nombre,
        COALESCE(a.total_adeudo, 0.00) as total_adeudos,
        COALESCE(p.total_pago, 0.00) as total_pagos,
        (COALESCE(a.total_adeudo, 0.00) - COALESCE(p.total_pago, 0.00)) as saldo,
        p.ultimo_pago_fecha as ultimo_pago,
        COALESCE(a.periodos, 0) as periodos_adeudo
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m ON m.num_mercado_nvo = l.num_mercado
    LEFT JOIN adeudos_por_local a ON a.id_local = l.id_local
    LEFT JOIN pagos_por_local p ON p.id_local = l.id_local
    WHERE m.oficina = p_oficina
      AND l.num_mercado = p_mercado
    ORDER BY
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
$$;

-- Comentarios para documentación
COMMENT ON FUNCTION public.sp_rpt_saldos_locales(INTEGER, INTEGER, INTEGER) IS
'Reporte de saldos de locales por mercado. Muestra adeudos, pagos y saldo pendiente por local.';
