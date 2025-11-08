-- Stored Procedure: rep_est_lic_report1
-- Tipo: Report
-- Descripción: Licencias dadas de alta en un rango de tiempo (por giro y zona)
-- Generado para formulario: repEstadisticosLicfrm
-- Fecha: 2025-08-26 17:53:26

CREATE OR REPLACE FUNCTION rep_est_lic_report1(fecha1 DATE, fecha2 DATE)
RETURNS TABLE(
  id_giro INTEGER,
  descripcion TEXT,
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
  SELECT l.id_giro, c.descripcion,
    COUNT(l1.zona) AS z_1,
    COUNT(l2.zona) AS z_2,
    COUNT(l3.zona) AS z_3,
    COUNT(l4.zona) AS z_4,
    COUNT(l5.zona) AS z_5,
    COUNT(l6.zona) AS z_6,
    COUNT(l7.zona) AS z_7,
    COUNT(l8.id_licencia) AS otros,
    COUNT(l9.id_licencia) AS total
  FROM licencias l
    LEFT JOIN licencias l1 ON l1.id_licencia = l.id_licencia AND l1.zona = 1
    LEFT JOIN licencias l2 ON l2.id_licencia = l.id_licencia AND l2.zona = 2
    LEFT JOIN licencias l3 ON l3.id_licencia = l.id_licencia AND l3.zona = 3
    LEFT JOIN licencias l4 ON l4.id_licencia = l.id_licencia AND l4.zona = 4
    LEFT JOIN licencias l5 ON l5.id_licencia = l.id_licencia AND l5.zona = 5
    LEFT JOIN licencias l6 ON l6.id_licencia = l.id_licencia AND l6.zona = 6
    LEFT JOIN licencias l7 ON l7.id_licencia = l.id_licencia AND l7.zona = 7
    LEFT JOIN licencias l8 ON l8.id_licencia = l.id_licencia AND (l8.zona IS NULL OR l8.zona NOT IN (1,2,3,4,5,6,7))
    LEFT JOIN licencias l9 ON l9.id_licencia = l.id_licencia
    JOIN c_giros c ON c.id_giro = l.id_giro
  WHERE l.vigente = 'V' AND l.fecha_otorgamiento >= fecha1 AND l.fecha_otorgamiento <= fecha2
  GROUP BY l.id_giro, c.descripcion
  ORDER BY l.id_giro;
END;
$$ LANGUAGE plpgsql;