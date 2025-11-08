-- Stored Procedure: sp_adeudos_updexed_search
-- Tipo: CRUD
-- Descripción: Busca la excedencia vigente para un contrato, periodo y tipo de operación.
-- Generado para formulario: Adeudos_UpdExed
-- Fecha: 2025-08-27 13:55:12

CREATE OR REPLACE FUNCTION sp_adeudos_updexed_search(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    ctrol_recolec INTEGER,
    costo_exed NUMERIC,
    aso_mes_oblig DATE,
    exedencias INTEGER,
    importe NUMERIC,
    aso_mes_pago VARCHAR,
    status_vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, c.costo_exed, a.aso_mes_oblig,
           p.exedencias, p.importe, p.aso_mes_pago, p.status_vigencia
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
    JOIN ta_16_pagos p ON p.control_contrato = a.control_contrato
        AND p.aso_mes_pago = lpad(p_ejercicio::text,4,'0')||'-'||lpad(p_mes::text,2,'0')
        AND p.ctrol_operacion = p_ctrol_operacion
        AND p.status_vigencia = 'V'
    WHERE a.num_contrato = p_num_contrato AND a.ctrol_aseo = p_ctrol_aseo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;