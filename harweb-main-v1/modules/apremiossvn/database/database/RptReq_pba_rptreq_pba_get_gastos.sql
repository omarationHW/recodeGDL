-- Stored Procedure: rptreq_pba_get_gastos
-- Tipo: Report
-- Descripción: Obtiene los gastos de requerimiento para un año y mes dados.
-- Generado para formulario: RptReq_pba
-- Fecha: 2025-08-27 15:11:39

CREATE OR REPLACE FUNCTION rptreq_pba_get_gastos(
    axo integer,
    mes integer
) RETURNS TABLE (
    fecha_axo integer,
    fecha_mes smallint,
    gtos_notif numeric,
    gtos_requer numeric,
    gtos_requer_anual numeric,
    gtos_secue numeric,
    gtos_secue_anual numeric,
    gtos_embar numeric,
    gtos_embar_anual numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha_axo, fecha_mes, gtos_notif, gtos_requer, gtos_requer_anual, gtos_secue, gtos_secue_anual, gtos_embar, gtos_embar_anual
    FROM ta_15_gastos
    WHERE fecha_axo = axo AND fecha_mes = mes;
END;
$$ LANGUAGE plpgsql;