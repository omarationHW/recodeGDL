-- Stored Procedure: sp_rpt_adeudo_corte_manzana_saldo_ant
-- Tipo: Report
-- Descripción: Obtiene el reporte de corte por manzana con saldo anterior para predios regularizados.
-- Generado para formulario: RptAdeudoCorteManzanaSaldoAnt
-- Fecha: 2025-08-27 15:20:14

-- PostgreSQL stored procedure for RptAdeudoCorteManzanaSaldoAnt
CREATE OR REPLACE FUNCTION sp_rpt_adeudo_corte_manzana_saldo_ant(
    p_subtipo integer,
    p_fechadsd date,
    p_fechahst date,
    p_rep integer,
    p_est varchar
)
RETURNS TABLE (
    id_conv_predio integer,
    tipo smallint,
    subtipo smallint,
    manzana varchar,
    lote integer,
    letra varchar,
    letracomp varchar,
    nombre varchar,
    calle varchar,
    num_exterior smallint,
    num_interior smallint,
    inciso varchar,
    cantidad_total numeric,
    parcpag float,
    pagos numeric,
    desc_subtipo varchar,
    recargos numeric,
    SaldoAnterior numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_conv_predio,
        a.tipo,
        a.subtipo,
        a.manzana,
        a.lote,
        a.letra,
        CASE WHEN a.letra = 'B' THEN 'BIS' WHEN a.letra = 'S' THEN 'SUB' ELSE ' ' END AS letracomp,
        b.nombre,
        b.calle,
        b.num_exterior,
        b.num_interior,
        b.inciso,
        b.cantidad_total,
        COUNT(c.id_conv_resto)::float AS parcpag,
        COALESCE(SUM(c.importe_pago),0) AS pagos,
        d.desc_subtipo,
        COALESCE(SUM(c.importe_recargo),0) AS recargos,
        (
            SELECT COALESCE(b2.cantidad_total,0) - COALESCE(SUM(c2.importe_pago),0)
            FROM ta_17_con_reg_pred a2
            JOIN ta_17_conv_d_resto b2 ON a2.tipo = b2.tipo AND a2.id_conv_predio = b2.id_conv_diver
            LEFT JOIN ta_17_conv_pagos c2 ON b2.id_conv_resto = c2.id_conv_resto AND c2.fecha_pago < p_fechadsd
            WHERE a2.tipo = 14 AND a2.subtipo = p_subtipo AND a2.id_conv_predio = a.id_conv_predio
            GROUP BY b2.cantidad_total
        ) AS SaldoAnterior
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago BETWEEN p_fechadsd AND p_fechahst
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    WHERE a.tipo = 14
      AND a.subtipo = p_subtipo
      AND b.vigencia = p_est
    GROUP BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, d.desc_subtipo
    ORDER BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra;
END;
$$ LANGUAGE plpgsql;