-- Stored Procedure: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para recargos de un mes dado
-- Generado para formulario: ConsultaDatosEnergia
-- Fecha: 2025-08-26 23:25:04

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_mes SMALLINT)
RETURNS TABLE (
  dia SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_limite)::SMALLINT FROM ta_12_diaslimite WHERE EXTRACT(MONTH FROM fecha_limite) = p_mes;
END;
$$ LANGUAGE plpgsql;