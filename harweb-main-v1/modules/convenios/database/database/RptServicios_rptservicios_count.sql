-- Stored Procedure: rptservicios_count
-- Tipo: Report
-- Descripción: Devuelve el total de servicios registrados en el catálogo.
-- Generado para formulario: RptServicios
-- Fecha: 2025-08-27 15:51:52

CREATE OR REPLACE FUNCTION rptservicios_count()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    total integer;
BEGIN
    SELECT COUNT(*) INTO total FROM ta_17_servicios;
    RETURN total;
END;
$$;