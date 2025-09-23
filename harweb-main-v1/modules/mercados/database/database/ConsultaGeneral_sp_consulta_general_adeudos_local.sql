-- Stored Procedure: sp_consulta_general_adeudos_local
-- Tipo: CRUD
-- Descripción: Obtiene adeudos de un local
-- Generado para formulario: ConsultaGeneral
-- Fecha: 2025-08-27 20:45:14

CREATE OR REPLACE FUNCTION sp_consulta_general_adeudos_local(
    p_id_local integer
) RETURNS TABLE(
    axo integer,
    periodo integer,
    importe numeric,
    recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.periodo, a.importe,
      COALESCE((a.importe * (
        SELECT SUM(porcentaje_mes) FROM ta_12_recargos r
        WHERE (r.axo = a.axo AND r.mes >= a.periodo)
      ) / 100), 0) as recargos
    FROM ta_11_adeudo_local a
    WHERE a.id_local = p_id_local
    ORDER BY a.axo, a.periodo;
END;
$$ LANGUAGE plpgsql;