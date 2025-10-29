-- Stored Procedure: get_concesion_by_control
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la concesión/local por su control (clave).
-- Generado para formulario: RConsulta
-- Fecha: 2025-08-28 13:38:15

CREATE OR REPLACE FUNCTION get_concesion_by_control(p_control TEXT)
RETURNS TABLE(
    id_34_datos INTEGER,
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fecha_inicio DATE,
    id_recaudadora INTEGER,
    sector TEXT,
    id_zona INTEGER,
    licencia INTEGER,
    descrip_unidad TEXT,
    cve_stat TEXT,
    descrip_stat TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_datos, a.control, a.concesionario, a.ubicacion, a.superficie, a.fecha_inicio,
           a.id_recaudadora, a.sector, a.id_zona, a.licencia, b.descripcion AS descrip_unidad,
           c.cve_stat, c.descripcion AS descrip_stat
    FROM t34_datos a
    JOIN t34_unidades b ON b.id_34_unidad = a.id_unidad
    JOIN t34_status c ON c.id_34_stat = a.id_stat
    WHERE a.cve_tab = 3 AND a.control = p_control;
END;
$$ LANGUAGE plpgsql;