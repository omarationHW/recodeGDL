-- Stored Procedure: sp_parcialidades_vencidas_conv_diversos
-- Tipo: Report
-- Descripción: Reporte de parcialidades vencidas de convenios diversos, agrupando por convenio y mostrando pagos al corriente, vencidos y adeudos.
-- Generado para formulario: RptParcVencidasConvDiversos
-- Fecha: 2025-08-27 15:48:12

-- PostgreSQL stored procedure for Parcialidades Vencidas Conv Diversos
CREATE OR REPLACE FUNCTION sp_parcialidades_vencidas_conv_diversos(
    p_tipo INTEGER,
    p_subtipo INTEGER,
    p_fechahst DATE,
    p_letras VARCHAR,
    p_est VARCHAR
)
RETURNS TABLE (
    id_conv_diver INTEGER,
    tipo INTEGER,
    subtipo INTEGER,
    letras_exp VARCHAR,
    numero_exp INTEGER,
    axo_exp INTEGER,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior INTEGER,
    num_interior INTEGER,
    inciso VARCHAR,
    costo NUMERIC,
    parcpag NUMERIC,
    pagos NUMERIC,
    recargos NUMERIC,
    venc INTEGER,
    parcade NUMERIC,
    adeudos NUMERIC,
    descripcion VARCHAR,
    desc_subtipo VARCHAR,
    oficio VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    -- Pagos al corriente y vencidos
    SELECT 
        a.id_conv_diver, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp,
        b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso,
        b.cantidad_total AS costo,
        COUNT(c.id_conv_resto) AS parcpag,
        COALESCE(SUM(c.importe_pago),0) AS pagos,
        COALESCE(SUM(c.importe_recargo),0) AS recargos,
        c.cve_venc AS venc,
        0 AS parcade,
        0 AS adeudos,
        i.descripcion, d.desc_subtipo,
        a.letras_exp || '/' || a.numero_exp::text || '/' || a.axo_exp::text AS oficio
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago <= p_fechahst
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    JOIN ta_17_tipos i ON a.tipo = i.tipo
    WHERE a.tipo = p_tipo
      AND a.subtipo = p_subtipo
      AND a.letras_exp = p_letras
      AND b.vigencia = p_est
    GROUP BY a.id_conv_diver, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp,
        b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, c.cve_venc, i.descripcion, d.desc_subtipo

    UNION
    -- Adeudos vencidos
    SELECT 
        e.id_conv_diver, e.tipo, e.subtipo, e.letras_exp, e.numero_exp, e.axo_exp,
        f.nombre, f.calle, f.num_exterior, f.num_interior, f.inciso,
        0 AS costo,
        0 AS parcpag,
        0 AS pagos,
        0 AS recargos,
        3 AS venc,
        COUNT(h.id_conv_resto) AS parcade,
        SUM(h.importe) AS adeudos,
        j.descripcion, g.desc_subtipo,
        e.letras_exp || '/' || e.numero_exp::text || '/' || e.axo_exp::text AS oficio
    FROM ta_17_conv_diverso e
    JOIN ta_17_conv_d_resto f ON e.tipo = f.tipo AND e.id_conv_diver = f.id_conv_diver
    LEFT JOIN ta_17_adeudos_div h ON f.id_conv_resto = h.id_conv_resto AND h.fecha_venc < p_fechahst AND h.clave_pago IS NULL
    JOIN ta_17_subtipo_conv g ON e.tipo = g.tipo AND e.subtipo = g.subtipo
    JOIN ta_17_tipos j ON e.tipo = j.tipo
    WHERE e.tipo = p_tipo
      AND e.subtipo = p_subtipo
      AND e.letras_exp = p_letras
      AND f.vigencia = p_est
    GROUP BY e.id_conv_diver, e.tipo, e.subtipo, e.letras_exp, e.numero_exp, e.axo_exp,
        f.nombre, f.calle, f.num_exterior, f.num_interior, f.inciso, j.descripcion, g.desc_subtipo
    ORDER BY 2,3,4,5;
END;
$$ LANGUAGE plpgsql;
