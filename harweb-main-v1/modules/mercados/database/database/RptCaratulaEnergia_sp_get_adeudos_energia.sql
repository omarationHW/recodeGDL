-- Stored Procedure: sp_get_adeudos_energia
-- Tipo: Report
-- Descripción: Obtiene los adeudos de energía para un local
-- Generado para formulario: RptCaratulaEnergia
-- Fecha: 2025-08-27 00:46:24

CREATE OR REPLACE FUNCTION sp_get_adeudos_energia(p_id_local INTEGER)
RETURNS TABLE (
    id_adeudo_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_adeudo_energia,
        a.id_energia,
        a.axo,
        a.periodo,
        a.importe,
        sp_calcular_recargos_energia(a.id_adeudo_energia) AS recargos
    FROM ta_11_adeudo_energ a
    JOIN ta_11_energia e ON e.id_energia = a.id_energia
    WHERE e.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;