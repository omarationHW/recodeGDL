-- Stored Procedure: sp_get_recargos_mes_abastos
-- Tipo: Report
-- Descripción: Obtiene los recargos del mes para abastos.
-- Generado para formulario: RptEmisionRbosAbastos
-- Fecha: 2025-08-27 00:59:26
-- CORREGIDO: Esquemas cross-database según postgreok.csv

CREATE OR REPLACE FUNCTION public.sp_get_recargos_mes_abastos(
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
    SELECT r.axo, r.mes, r.porcentaje_mes, r.acumulado_uno, r.acumulado_dos, r.acumulado_tres
    FROM padron_licencias.comun.ta_12_recargos r
    WHERE r.axo = p_axo AND r.mes = p_mes;
END;
$$ LANGUAGE plpgsql;
