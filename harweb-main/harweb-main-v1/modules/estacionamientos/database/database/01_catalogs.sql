CREATE OR REPLACE FUNCTION get_periodo_diario()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'C' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_periodo_altas()
RETURNS TABLE(fecha_inicio date, fecha_fin date) AS $$
BEGIN
    RETURN QUERY SELECT fecha_inicio, fecha_fin FROM ta14_bitacora WHERE tipo = 'B' ORDER BY fecha_fin DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;