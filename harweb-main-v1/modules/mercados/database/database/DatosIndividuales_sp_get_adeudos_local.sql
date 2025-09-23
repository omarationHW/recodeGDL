-- Stored Procedure: sp_get_adeudos_local
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_adeudos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo, a.periodo, a.importe,
        (a.importe * COALESCE((SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE axo = a.axo AND mes >= a.periodo),0)/100) AS recargos
    FROM ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;