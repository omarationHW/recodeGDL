-- Stored Procedure: sp_gadeudos_busca
-- Tipo: Report
-- Descripción: Busca el registro de concesión/control para GAdeudos por tabla y control
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-28 12:49:54

CREATE OR REPLACE FUNCTION sp_gadeudos_busca(par_tab TEXT, par_control TEXT)
RETURNS TABLE(
    control TEXT,
    concesionario TEXT,
    ubicacion TEXT,
    superficie NUMERIC,
    fechainicio DATE,
    fechafin DATE,
    recaudadora INTEGER,
    sector TEXT,
    zona INTEGER,
    licencia INTEGER,
    unidades TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.control, d.concesionario, d.ubicacion, d.superficie, d.fecha_inicio, d.fecha_fin, d.id_recaudadora, d.sector, d.id_zona, d.licencia, u.descripcion as unidades
    FROM t34_datos d
    LEFT JOIN t34_unidades u ON u.cve_tab = d.cve_tab
    WHERE d.cve_tab = par_tab AND d.control = par_control
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;