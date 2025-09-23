-- Stored Procedure: sp_get_recargos_energia
-- Tipo: Catalog
-- Descripción: Obtiene el porcentaje de recargos para un año y mes
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

CREATE OR REPLACE FUNCTION sp_get_recargos_energia(p_axo SMALLINT, p_mes SMALLINT)
RETURNS TABLE (
  porcentaje NUMERIC
) AS $$
BEGIN
  RETURN QUERY
    SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE axo = p_axo AND mes >= p_mes;
END;
$$ LANGUAGE plpgsql;