-- Stored Procedure: rptreq_pba_aseo_get_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite de corte para un mes dado.
-- Generado para formulario: RptReq_Pba_Aseo
-- Fecha: 2025-08-27 15:15:15

CREATE OR REPLACE FUNCTION rptreq_pba_aseo_get_limite(
    p_mes INTEGER
)
RETURNS TABLE (
    mes SMALLINT,
    dia SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, dia FROM ta_16_dia_limite WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;