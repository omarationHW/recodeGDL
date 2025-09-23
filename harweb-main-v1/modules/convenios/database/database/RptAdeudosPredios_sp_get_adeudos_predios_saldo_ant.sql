-- Stored Procedure: sp_get_adeudos_predios_saldo_ant
-- Tipo: Report
-- Descripción: Obtiene el reporte de adeudos de predios con saldo anterior, por subtipo, rango de fechas y estado.
-- Generado para formulario: RptAdeudosPredios
-- Fecha: 2025-08-27 15:27:12

CREATE OR REPLACE FUNCTION sp_get_adeudos_predios_saldo_ant(
    p_subtipo INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_estado VARCHAR
)
RETURNS TABLE(
    id_conv_predio INTEGER,
    tipo SMALLINT,
    subtipo SMALLINT,
    manzana VARCHAR,
    lote INTEGER,
    letra VARCHAR,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior SMALLINT,
    num_interior SMALLINT,
    inciso VARCHAR,
    cantidad_total NUMERIC,
    parcpag NUMERIC,
    pagos NUMERIC,
    desc_subtipo VARCHAR,
    recargos NUMERIC,
    letracomp VARCHAR,
    saldo_anterior NUMERIC
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
        CASE WHEN a.letra = 'B' THEN 'BIS' WHEN a.letra = 'S' THEN 'SUB' ELSE ' ' END AS letracomp,
        (
            SELECT COALESCE(b2.cantidad_total,0) - COALESCE(SUM(c2.importe_pago),0)
            FROM ta_17_conv_d_resto b2
            LEFT JOIN ta_17_conv_pagos c2 ON b2.id_conv_resto = c2.id_conv_resto AND c2.fecha_pago < p_fecha_desde
            WHERE b2.id_conv_resto = b.id_conv_resto
            GROUP BY b2.cantidad_total
        ) AS saldo_anterior
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    JOIN ta_17_subtipo_conv d ON a.tipo = d.tipo AND a.subtipo = d.subtipo
    WHERE a.tipo = 14
      AND a.subtipo = p_subtipo
      AND b.vigencia = p_estado
    GROUP BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, d.desc_subtipo, b.id_conv_resto
    ORDER BY a.id_conv_predio, a.tipo, a.subtipo, a.manzana, a.lote, a.letra;
END;
$$ LANGUAGE plpgsql;