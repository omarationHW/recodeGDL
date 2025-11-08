-- Stored Procedure: sp_rep_estadisticos_lic_reglamentadas_rango
-- Tipo: Report
-- Descripción: Reporte de licencias reglamentadas dadas de alta en un rango de fechas, agrupadas por giro y zona.
-- Generado para formulario: repEstadisticosLicfrm
-- Fecha: 2025-08-27 19:20:47

CREATE OR REPLACE FUNCTION sp_rep_estadisticos_lic_reglamentadas_rango(fecha1 DATE, fecha2 DATE, clasificacion TEXT DEFAULT NULL)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion TEXT,
    clasificacion TEXT,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_giro,
        c.descripcion,
        c.clasificacion,
        COUNT(CASE WHEN l.zona = 1 THEN 1 END) AS z_1,
        COUNT(CASE WHEN l.zona = 2 THEN 1 END) AS z_2,
        COUNT(CASE WHEN l.zona = 3 THEN 1 END) AS z_3,
        COUNT(CASE WHEN l.zona = 4 THEN 1 END) AS z_4,
        COUNT(CASE WHEN l.zona = 5 THEN 1 END) AS z_5,
        COUNT(CASE WHEN l.zona = 6 THEN 1 END) AS z_6,
        COUNT(CASE WHEN l.zona = 7 THEN 1 END) AS z_7,
        COUNT(CASE WHEN l.zona IS NULL OR l.zona NOT IN (1,2,3,4,5,6,7) THEN 1 END) AS otros,
        COUNT(*) AS total
    FROM licencias l
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE l.vigente = 'V'
      AND l.fecha_otorgamiento >= fecha1
      AND l.fecha_otorgamiento <= fecha2
      AND (
        (clasificacion IS NULL AND (c.clasificacion = 'C' OR c.clasificacion = 'D')) OR
        (clasificacion IS NOT NULL AND c.clasificacion = clasificacion)
      )
    GROUP BY l.id_giro, c.descripcion, c.clasificacion
    ORDER BY c.clasificacion, c.descripcion;
END;
$$ LANGUAGE plpgsql;