-- Stored Procedure: sp_adeudos_pagmult_listar_adeudos
-- Tipo: CRUD
-- Descripción: Lista los adeudos vigentes de un contrato.
-- Generado para formulario: Adeudos_PagMult
-- Fecha: 2025-08-27 13:51:30

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_listar_adeudos(p_control_contrato integer)
RETURNS TABLE(
    control_contrato integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar,
    descripcion varchar,
    exedencias smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.cve_operacion, b.descripcion, a.exedencias, a.importe
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V'
    ORDER BY a.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;