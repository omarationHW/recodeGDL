-- Stored Procedure: sp_total_sanandres
-- Tipo: Report
-- Descripción: Devuelve el total de registros de la tabla 'datos' para paginación.
-- Generado para formulario: ConsultaSAndres
-- Fecha: 2025-08-27 14:24:28

CREATE OR REPLACE FUNCTION sp_total_sanandres()
RETURNS integer AS $$
DECLARE
    total integer;
BEGIN
    SELECT COUNT(*) INTO total FROM datos;
    RETURN total;
END;
$$ LANGUAGE plpgsql;