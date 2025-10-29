-- Stored Procedure: sp_get_dias_inhabiles
-- Tipo: Catalog
-- Descripción: Obtiene los días inhábiles para una fecha dada
-- Generado para formulario: IndividualPredios
-- Fecha: 2025-08-27 14:45:56

CREATE OR REPLACE FUNCTION sp_get_dias_inhabiles(p_fecha DATE)
RETURNS TABLE (fecha DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT fecha FROM ta_12_diasinhabil WHERE fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;