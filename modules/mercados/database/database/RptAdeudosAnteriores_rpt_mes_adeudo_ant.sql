-- Stored Procedure: rpt_mes_adeudo_ant
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo para un local y año específico.
-- Generado para formulario: RptAdeudosAnteriores
-- Fecha: 2025-08-27 00:39:09

CREATE OR REPLACE FUNCTION rpt_mes_adeudo_ant(p_id_local INTEGER, p_axo INTEGER)
RETURNS TABLE(
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_local, axo, periodo, importe
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo
    ORDER BY id_local, axo, periodo;
END;
$$ LANGUAGE plpgsql;