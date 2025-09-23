-- Stored Procedure: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para recargos según el mes
-- Generado para formulario: RptCaratulaEnergia
-- Fecha: 2025-08-27 00:46:24

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_mes SMALLINT)
RETURNS TABLE (dia SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_limite)::SMALLINT
    FROM ta_12_diaslimite
    WHERE EXTRACT(MONTH FROM fecha_limite) = p_mes
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;