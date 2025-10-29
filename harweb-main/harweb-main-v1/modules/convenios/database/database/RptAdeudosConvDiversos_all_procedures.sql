-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptAdeudosConvDiversos
-- Generado: 2025-08-27 15:23:56
-- Total SPs: 3
-- ============================================

-- SP 1/3: rpt_adeudos_conv_diversos
-- Tipo: Report
-- Descripción: Reporte de adeudos de convenios diversos por tipo, subtipo, zona, estado y fecha de corte.
-- --------------------------------------------

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

-- ============================================

-- SP 2/3: rpt_adeudos_conv_diversos_detalle
-- Tipo: Report
-- Descripción: Detalle de pagos y parcialidades de un convenio diverso.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_adeudos_conv_diversos_detalle(
    p_id_conv_diver integer
) RETURNS TABLE(
    id_conv_resto integer,
    fecha_pago date,
    importe_pago numeric,
    importe_recargo numeric,
    pago_parcial integer,
    total_parciales integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cp.id_conv_resto,
        cp.fecha_pago,
        cp.importe_pago,
        cp.importe_recargo,
        cp.pago_parcial,
        cp.total_parciales
    FROM ta_17_conv_pagos cp
    JOIN ta_17_conv_d_resto cr ON cp.id_conv_resto = cr.id_conv_resto
    WHERE cr.id_conv_diver = p_id_conv_diver
    ORDER BY cp.fecha_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: rpt_adeudos_conv_diversos_resumen
-- Tipo: Report
-- Descripción: Resumen de adeudos de convenios diversos agrupado por zona y estado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_adeudos_conv_diversos_resumen(
    p_tipo integer,
    p_subtipo integer,
    p_letras varchar,
    p_estado varchar,
    p_fecha date
) RETURNS TABLE(
    zona varchar,
    total_convenios integer,
    total_costo numeric,
    total_pagos numeric,
    total_saldo numeric,
    total_recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE a.letras_exp
            WHEN 'ZC1' THEN 'Zona Centro'
            WHEN 'ZO2' THEN 'Zona Olímpica'
            WHEN 'ZO3' THEN 'Zona Oblatos'
            WHEN 'ZM4' THEN 'Zona Minerva'
            WHEN 'ZC5' THEN 'Zona Cruz del Sur'
            ELSE a.letras_exp
        END AS zona,
        COUNT(DISTINCT a.id_conv_diver) AS total_convenios,
        SUM(b.cantidad_total) AS total_costo,
        SUM(COALESCE(c.pagos,0)) AS total_pagos,
        SUM(b.cantidad_total - COALESCE(c.pagos,0)) AS total_saldo,
        SUM(COALESCE(c.recargos,0)) AS total_recargos
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    LEFT JOIN (
        SELECT id_conv_resto, SUM(importe_pago) AS pagos, SUM(importe_recargo) AS recargos
        FROM ta_17_conv_pagos
        WHERE fecha_pago <= p_fecha
        GROUP BY id_conv_resto
    ) c ON b.id_conv_resto = c.id_conv_resto
    WHERE a.tipo = p_tipo
      AND a.subtipo = p_subtipo
      AND a.letras_exp = p_letras
      AND b.vigencia = p_estado
    GROUP BY zona;
END;
$$ LANGUAGE plpgsql;

-- ============================================

