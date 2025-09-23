-- Stored Procedure: sp_pagos_con_fpgo_get_contrato_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de un contrato por control_contrato
-- Generado para formulario: Pagos_Con_FPgo
-- Fecha: 2025-08-27 15:02:16

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_contrato_detalle(p_control_contrato INTEGER)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    costo_unidad NUMERIC,
    aso_mes_oblig VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_contrato,
        a.num_contrato,
        a.ctrol_aseo,
        c.tipo_aseo,
        c.descripcion,
        a.ctrol_recolec,
        a.cantidad_recolec,
        b.costo_unidad,
        to_char(a.aso_mes_oblig, 'YYYY-MM') as aso_mes_oblig
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN ta_16_tipo_aseo c ON c.ctrol_aseo = a.ctrol_aseo
    WHERE a.control_contrato = p_control_contrato
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;