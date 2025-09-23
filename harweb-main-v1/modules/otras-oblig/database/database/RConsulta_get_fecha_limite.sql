-- Stored Procedure: get_fecha_limite
-- Tipo: Catalog
-- Descripción: Obtiene la fecha límite del periodo actual.
-- Generado para formulario: RConsulta
-- Fecha: 2025-08-28 13:38:15

CREATE OR REPLACE FUNCTION get_fecha_limite()
RETURNS TABLE(fechalimite DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT fechalimite
    FROM t34_fechalimite
    WHERE EXTRACT(YEAR FROM fechalimite) = EXTRACT(YEAR FROM CURRENT_DATE)
      AND EXTRACT(MONTH FROM fechalimite) = EXTRACT(MONTH FROM CURRENT_DATE)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;