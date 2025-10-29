-- Stored Procedure: sp_get_meses_adeudo_energia
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de energía eléctrica para un id_energia y año/mes.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 00:15:05

CREATE OR REPLACE FUNCTION sp_get_meses_adeudo_energia(
    p_id_energia integer,
    p_axo integer,
    p_mes integer
) RETURNS TABLE(
    periodo smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT periodo, importe
    FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia
      AND (axo = p_axo AND periodo <= p_mes)
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;