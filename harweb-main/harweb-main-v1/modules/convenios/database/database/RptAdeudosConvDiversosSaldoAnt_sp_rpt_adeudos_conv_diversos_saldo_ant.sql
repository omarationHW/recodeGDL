-- Stored Procedure: sp_rpt_adeudos_conv_diversos_saldo_ant
-- Tipo: Report
-- Descripción: Obtiene el reporte de convenios diversos con saldo anterior y pagos en un rango de fechas.
-- Generado para formulario: RptAdeudosConvDiversosSaldoAnt
-- Fecha: 2025-08-27 15:25:27

CREATE OR REPLACE FUNCTION sp_rpt_adeudos_conv_diversos_saldo_ant(
    p_tipo integer,
    p_subtipo integer,
    p_letras varchar,
    p_estado varchar,
    p_fechadsd date,
    p_fechahst date
)
RETURNS TABLE (
    id_conv_diver integer,
    tipo integer,
    subtipo integer,
    letras_exp varchar,
    numero_exp integer,
    axo_exp integer,
    nombre varchar,
    calle varchar,
    num_exterior integer,
    num_interior integer,
    inciso varchar,
    cantidad_total numeric,
    parcpag integer,
    pagos numeric,
    descripcion varchar,
    desc_subtipo varchar,
    recargos numeric,
    SaldoAnterior numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_conv_diver,
        a.tipo,
        a.subtipo,
        a.letras_exp,
        a.numero_exp,
        a.axo_exp,
        b.nombre,
        b.calle,
        b.num_exterior,
        b.num_interior,
        b.inciso,
        b.cantidad_total,
        COUNT(c.id_conv_resto) AS parcpag,
        COALESCE(SUM(c.importe_pago),0) AS pagos,
        e.descripcion,
        d.desc_subtipo,
        COALESCE(SUM(c.importe_recargo),0) AS recargos,
        (
            SELECT b2.cantidad_total - COALESCE(SUM(c2.importe_pago),0)
            FROM ta_17_conv_diverso a2
            JOIN ta_17_conv_d_resto b2 ON a2.tipo = b2.tipo AND a2.id_conv_diver = b2.id_conv_diver
            LEFT JOIN ta_17_conv_pagos c2 ON b2.id_conv_resto = c2.id_conv_resto AND c2.fecha_pago < p_fechadsd
            WHERE a2.tipo = p_tipo AND a2.subtipo = p_subtipo AND a2.id_conv_diver = a.id_conv_diver
            GROUP BY b2.cantidad_total
        ) AS SaldoAnterior
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago BETWEEN p_fechadsd AND p_fechahst
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    JOIN ta_17_tipos e ON a.tipo = e.tipo
    WHERE a.tipo = p_tipo
      AND a.subtipo = p_subtipo
      AND a.letras_exp = p_letras
      AND b.vigencia = p_estado
    GROUP BY a.id_conv_diver, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp,
             b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total,
             e.descripcion, d.desc_subtipo
    ORDER BY a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp;
END;
$$ LANGUAGE plpgsql;