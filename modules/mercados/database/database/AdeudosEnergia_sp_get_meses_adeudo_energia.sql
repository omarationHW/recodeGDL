-- Stored Procedure: sp_get_meses_adeudo_energia
-- Tipo: Report
-- Descripción: Obtiene los meses y cuotas de adeudo de energía para un id_energia y año.
-- Generado para formulario: AdeudosEnergia
-- Fecha: 2025-08-26 20:50:21

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo_energia(p_id_energia INTEGER, p_axo INTEGER)
RETURNS TABLE(
    periodo SMALLINT,
    importe NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT periodo, importe
    FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;