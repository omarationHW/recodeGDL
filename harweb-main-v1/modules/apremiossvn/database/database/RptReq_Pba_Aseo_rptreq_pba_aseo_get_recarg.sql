-- Stored Procedure: rptreq_pba_aseo_get_recarg
-- Tipo: Catalog
-- Descripción: Obtiene el porcentaje de recargos acumulados entre dos fechas.
-- Generado para formulario: RptReq_Pba_Aseo
-- Fecha: 2025-08-27 15:15:15

CREATE OR REPLACE FUNCTION rptreq_pba_aseo_get_recarg(
    p_axo_inicio INTEGER,
    p_mes_inicio INTEGER,
    p_axo_fin INTEGER
)
RETURNS TABLE (
    porcentaje NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT SUM(porcentaje_mes) AS porcentaje
    FROM ta_12_recargos
    WHERE (axo = p_axo_inicio AND mes >= p_mes_inicio)
       OR (axo = p_axo_fin AND mes <= EXTRACT(MONTH FROM CURRENT_DATE))
       OR (axo > p_axo_inicio AND axo < p_axo_fin);
END;
$$ LANGUAGE plpgsql;