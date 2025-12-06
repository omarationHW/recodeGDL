-- Stored Procedure: sp_get_adeudos_local
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos de un local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

DROP FUNCTION IF EXISTS sp_get_adeudos_local(INTEGER);

CREATE OR REPLACE FUNCTION sp_get_adeudos_local(p_id_local INTEGER)
RETURNS TABLE (
    id_local INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    importe NUMERIC(16,2),
    recargos NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.axo, a.periodo, a.importe,
        (a.importe * COALESCE((SELECT SUM(r.porcentaje_mes) FROM publico.ta_12_recargos r WHERE r.axo = a.axo AND r.mes >= a.periodo),0)/100) AS recargos
    FROM publico.ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;