-- Stored Procedure: rptreq_pba_get_recargos
-- Tipo: Report
-- Descripción: Obtiene el porcentaje de recargos acumulado para un periodo de adeudo.
-- Generado para formulario: RptReq_pba
-- Fecha: 2025-08-27 15:11:39

CREATE OR REPLACE FUNCTION rptreq_pba_get_recargos(
    axo integer,
    periodo integer,
    vaxo integer,
    vmes integer,
    vdia integer
) RETURNS TABLE (
    porcentaje float
) AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(SUM(porcentaje_mes), 0) as porcentaje
    FROM ta_12_recargos
    WHERE (axo = axo AND mes >= periodo)
       OR (axo = vaxo AND mes <= (CASE WHEN vdia <= 12 THEN vmes - 1 ELSE vmes END))
       OR (axo > axo AND axo < vaxo);
END;
$$ LANGUAGE plpgsql;