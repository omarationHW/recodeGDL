-- Stored Procedure: sp_get_meses_adeudo
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de un local para un año y periodo dados.
-- Generado para formulario: RptAdeudosLocales
-- Fecha: 2025-08-27 00:42:39

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
    periodo smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT periodo, importe
    FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo <= p_periodo
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;