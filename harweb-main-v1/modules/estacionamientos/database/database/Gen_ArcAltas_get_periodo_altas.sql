-- Stored Procedure: get_periodo_altas
-- Tipo: Catalog
-- Descripción: Obtiene el último periodo de altas registrado.
-- Generado para formulario: Gen_ArcAltas
-- Fecha: 2025-08-27 13:40:51

-- PostgreSQL function to get last period
CREATE OR REPLACE FUNCTION get_periodo_altas()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;