-- Stored Procedure: rptreq_pba_aseo_get_gastos
-- Tipo: Catalog
-- Descripción: Obtiene los gastos de requerimiento para un año y mes dados.
-- Generado para formulario: RptReq_Pba_Aseo
-- Fecha: 2025-08-27 15:15:15

CREATE OR REPLACE FUNCTION rptreq_pba_aseo_get_gastos(
    p_axo INTEGER,
    p_mes INTEGER
)
RETURNS TABLE (
    fecha_axo INTEGER,
    fecha_mes SMALLINT,
    gtos_notif NUMERIC,
    gtos_requer NUMERIC,
    gtos_requer_anual NUMERIC,
    gtos_secue NUMERIC,
    gtos_secue_anual NUMERIC,
    gtos_embar NUMERIC,
    gtos_embar_anual NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_15_gastos WHERE fecha_axo = p_axo AND fecha_mes = p_mes;
END;
$$ LANGUAGE plpgsql;