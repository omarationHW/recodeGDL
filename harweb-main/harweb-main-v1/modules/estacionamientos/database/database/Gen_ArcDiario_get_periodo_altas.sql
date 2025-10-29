-- Stored Procedure: get_periodo_altas
-- Tipo: Catalog
-- Descripción: Obtiene el periodo de la última generación de altas (tipo 'B')
-- Generado para formulario: Gen_ArcDiario
-- Fecha: 2025-08-27 20:40:42

CREATE OR REPLACE FUNCTION get_periodo_altas()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;