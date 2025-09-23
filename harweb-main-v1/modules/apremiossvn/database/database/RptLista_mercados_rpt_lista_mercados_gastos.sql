-- Stored Procedure: rpt_lista_mercados_gastos
-- Tipo: Report
-- Descripción: Obtiene los gastos de notificación, requerimiento, embargo, etc. para un año y mes.
-- Generado para formulario: RptLista_mercados
-- Fecha: 2025-08-27 14:55:43

CREATE OR REPLACE FUNCTION rpt_lista_mercados_gastos(
    axo integer,
    mes integer
)
RETURNS TABLE (
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
    SELECT * FROM ta_15_gastos WHERE fecha_axo = axo AND fecha_mes = mes;
END;
$$ LANGUAGE plpgsql;
