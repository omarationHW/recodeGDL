-- Stored Procedure: sp_rpt_adeudos_predios_saldo_ant
-- Tipo: Report
-- Descripción: Reporte de adeudos de predios con saldo anterior en un rango de fechas y estado
-- Generado para formulario: RptAdeudosPrediosSaldoAnt
-- Fecha: 2025-08-27 15:28:57

-- PostgreSQL stored procedure for RptAdeudosPrediosSaldoAnt
CREATE OR REPLACE FUNCTION sp_rpt_adeudos_predios_saldo_ant(
    p_subtipo integer,
    p_fechadsd date,
    p_fechahst date,
    p_est char(1)
)
RETURNS TABLE(
    id_conv_predio integer,
    tipo smallint,
    subtipo smallint,
    manzana varchar(15),
    lote integer,
    letra char(1),
    nombre varchar(50),
    calle varchar(50),
    num_exterior smallint,
    num_interior smallint,
    inciso varchar(10),
    cantidad_total numeric,
    parcpag integer,
    pagos numeric,
    desc_subtipo varchar(50),
    recargos numeric,
    letracomp varchar(10),
    saldoanterior numeric
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
        b.nombre,
        b.calle,
        b.num_exterior,
        b.num_interior,
        b.inciso,
        b.cantidad_total,
        COUNT(c.id_conv_resto) AS parcpag,
        COALESCE(SUM(c.importe_pago),0) AS pagos,
        d.desc_subtipo,
        COALESCE(SUM(c.importe_recargo),0) AS recargos,
        CASE WHEN a.letra = 'B' THEN 'BIS' WHEN a.letra = 'S' THEN 'SUB' ELSE '' END AS letracomp,
        COALESCE(sa.cantidad_total,0) - COALESCE(sa.pagos,0) AS saldoanterior
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago BETWEEN p_fechadsd AND p_fechahst
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    LEFT JOIN (
        SELECT a2.id_conv_predio, b2.cantidad_total, COALESCE(SUM(c2.importe_pago),0) AS pagos
        FROM ta_17_con_reg_pred a2
        JOIN ta_17_conv_d_resto b2 ON a2.tipo = b2.tipo AND a2.id_conv_predio = b2.id_conv_diver
        LEFT JOIN ta_17_conv_pagos c2 ON b2.id_conv_resto = c2.id_conv_resto AND c2.fecha_pago < p_fechadsd
        WHERE a2.tipo = 14 AND a2.subtipo = p_subtipo
        GROUP BY a2.id_conv_predio, b2.cantidad_total
    ) sa ON sa.id_conv_predio = a.id_conv_predio
    WHERE a.tipo = 14
      AND a.subtipo = p_subtipo
      AND b.vigencia = p_est
    GROUP BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, d.desc_subtipo, sa.cantidad_total, sa.pagos;
END;
$$ LANGUAGE plpgsql;