-- Stored Procedure: sp_reporte_licencias
-- Tipo: Report
-- Descripción: Reporte de licencias por rango de fechas y giros
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-26 18:12:43

CREATE OR REPLACE FUNCTION sp_reporte_licencias(p_desde date, p_hasta date, p_giros integer[] DEFAULT NULL)
RETURNS TABLE(
    licencia integer,
    propietario text,
    actividad text,
    zona text,
    subzona text,
    fecha_otorgamiento date
) AS $$
BEGIN
    IF p_giros IS NULL THEN
        RETURN QUERY SELECT licencia, propietario, actividad, zona, subzona, fecha_otorgamiento FROM licencias WHERE fecha_otorgamiento BETWEEN p_desde AND p_hasta;
    ELSE
        RETURN QUERY SELECT licencia, propietario, actividad, zona, subzona, fecha_otorgamiento FROM licencias WHERE fecha_otorgamiento BETWEEN p_desde AND p_hasta AND id_giro = ANY(p_giros);
    END IF;
END;
$$ LANGUAGE plpgsql;