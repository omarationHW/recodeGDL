-- Stored Procedure: sp_get_recargos_mes_abastos
-- Tipo: Report
-- Descripción: Obtiene los recargos del mes para abastos.
-- Generado para formulario: RptEmisionRbosAbastos
-- Fecha: 2025-08-27 00:59:26

CREATE OR REPLACE FUNCTION sp_get_recargos_mes_abastos(
    p_axo integer,
    p_mes integer
) RETURNS TABLE (
    axo integer,
    mes integer,
    porcentaje_mes numeric,
    acumulado_uno numeric,
    acumulado_dos numeric,
    acumulado_tres numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT axo, mes, porcentaje_mes, acumulado_uno, acumulado_dos, acumulado_tres
    FROM ta_12_recargos
    WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;