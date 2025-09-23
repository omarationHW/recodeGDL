-- Stored Procedure: get_periodo_diario
-- Tipo: Catalog
-- Descripción: Obtiene el periodo de la última generación diaria (tipo 'C')
-- Generado para formulario: Gen_ArcDiario
-- Fecha: 2025-08-27 20:40:42

CREATE OR REPLACE FUNCTION get_periodo_diario()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'C' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;