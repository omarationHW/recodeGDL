-- Stored Procedure: sp_rpt_emision_rbos_abastos
-- Tipo: Report
-- Descripción: Obtiene el reporte de emisión de recibos de abastos para una oficina, mercado, año y periodo.
-- Generado para formulario: RptEmisionRbosAbastos
-- Fecha: 2025-12-05
-- CORREGIDO: Esquemas según publico/public

DROP FUNCTION IF EXISTS public.sp_rpt_emision_rbos_abastos(INTEGER, INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_emision_rbos_abastos(
    p_oficina integer,
    p_mercado integer,
    p_axo integer,
    p_periodo integer
) RETURNS TABLE (
    id_local integer,
    oficina integer,
    num_mercado integer,
    categoria integer,
    seccion text,
    local integer,
    letra_local text,
    bloque text,
    nombre text,
    descripcion text,
    descripcion_local text,
    axo_1 integer,
    categoria_1 integer,
    seccion_1 text,
    clave_cuota integer,
    importe_cuota numeric,
    renta numeric,
    rentaaxos numeric,
    meses text,
    adeudo numeric,
    recargos numeric,
    subtotal numeric,
    multa numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        base.id_local::INTEGER,
        base.oficina::INTEGER,
        base.num_mercado::INTEGER,
        base.categoria::INTEGER,
        base.seccion::TEXT,
        base.local::INTEGER,
        base.letra_local::TEXT,
        base.bloque::TEXT,
        base.nombre::TEXT,
        base.descripcion::TEXT,
        base.descripcion_local::TEXT,
        base.axo_1::INTEGER,
        base.categoria_1::INTEGER,
        base.seccion_1::TEXT,
        base.clave_cuota::INTEGER,
        base.importe_cuota::NUMERIC,
        -- Calcular renta
        CASE
            WHEN base.seccion = 'PS' THEN
                (base.importe_cuota * COALESCE(base.superficie, 1)) * 30
            ELSE
                COALESCE(base.superficie, 1) * base.importe_cuota
        END::NUMERIC AS renta,
        -- Rentaaxos - última renta del año
        COALESCE((
            SELECT MAX(ade.importe)
            FROM publico.ta_11_adeudo_local ade
            WHERE ade.id_local = base.id_local
            AND ade.axo = base.axo_1
            AND ((ade.axo < p_axo) OR (ade.axo = p_axo AND ade.periodo < p_periodo))
        ), 0)::NUMERIC AS rentaaxos,
        -- Meses - lista de periodos adeudados
        COALESCE((
            SELECT string_agg(ade2.periodo::text, ',' ORDER BY ade2.periodo)
            FROM publico.ta_11_adeudo_local ade2
            WHERE ade2.id_local = base.id_local
            AND ade2.axo = base.axo_1
            AND ((ade2.axo < p_axo) OR (ade2.axo = p_axo AND ade2.periodo < p_periodo))
        ), '')::TEXT AS meses,
        base.adeudo::NUMERIC,
        base.recargos::NUMERIC,
        -- Subtotal
        (base.adeudo + base.recargos + 0)::NUMERIC AS subtotal,
        0::NUMERIC AS multa
    FROM (
        SELECT
            a.id_local,
            a.oficina,
            a.num_mercado,
            a.categoria,
            a.seccion,
            a.local,
            a.letra_local,
            a.bloque,
            a.nombre,
            b.descripcion,
            a.descripcion_local,
            c.axo AS axo_1,
            c.categoria AS categoria_1,
            c.seccion AS seccion_1,
            c.clave_cuota,
            c.importe_cuota,
            a.superficie,
            COALESCE(SUM(d.importe),0) AS adeudo,
            COALESCE(SUM(ROUND((d.importe * (
                SELECT SUM(porcentaje_mes) FROM publico.ta_12_recargos WHERE (axo = d.axo AND mes >= d.periodo) OR (axo > d.axo)
            ))/100,2)),0) AS recargos
        FROM publico.ta_11_locales a
        JOIN publico.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
        JOIN public.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
        LEFT JOIN publico.ta_11_adeudo_local d ON a.id_local = d.id_local
        WHERE a.oficina = p_oficina
          AND a.num_mercado = p_mercado
          AND a.vigencia = 'A'
          AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
          AND a.id_local NOT IN (
              SELECT p.id_local FROM publico.ta_11_pagos_local p WHERE p.id_local = a.id_local AND p.axo = p_axo AND p.periodo = p_periodo
          )
        GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, b.descripcion, a.descripcion_local,
                 c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, a.superficie
    ) base
    ORDER BY base.oficina, base.num_mercado, base.categoria, base.seccion, base.local, base.letra_local, base.bloque, base.axo_1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_rpt_emision_rbos_abastos(INTEGER, INTEGER, INTEGER, INTEGER) IS
'Obtiene el reporte de emisión de recibos de abastos para una oficina, mercado, año y periodo.
Parámetros: p_oficina, p_mercado, p_axo, p_periodo.
Retorna: listado de locales con sus adeudos y cálculos de recargos.';
