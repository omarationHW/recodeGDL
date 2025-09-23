-- Stored Procedure: rpt_adeudos_conv_diversos
-- Tipo: Report
-- Descripción: Reporte de adeudos de convenios diversos por tipo, subtipo, zona, estado y fecha de corte.
-- Generado para formulario: RptAdeudosConvDiversos
-- Fecha: 2025-08-27 15:23:56

CREATE OR REPLACE FUNCTION rpt_adeudos_conv_diversos(
    p_tipo integer,
    p_subtipo integer,
    p_letras varchar,
    p_estado varchar,
    p_fecha date
) RETURNS TABLE(
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
    oficio varchar
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
        a.letras_exp || '/' || a.numero_exp::text || '/' || a.axo_exp::text AS oficio
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago <= p_fecha
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