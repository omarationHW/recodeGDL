-- Stored Procedure: rep_est_lic_report5
-- Tipo: Report
-- Descripción: Pagos de licencias en un rango de tiempo (por recaudadora y tipo de licencia)
-- Generado para formulario: repEstadisticosLicfrm
-- Fecha: 2025-08-26 17:53:26

CREATE OR REPLACE FUNCTION rep_est_lic_report5(fecha1 DATE, fecha2 DATE)
RETURNS TABLE(
  recaud INTEGER,
  cuantos INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.recaud, COUNT(*) AS cuantos
  FROM pagos p
    JOIN licencias l ON l.id_licencia = p.cvecuenta
    JOIN c_giros c ON c.id_giro = l.id_giro
  WHERE p.cveconcepto = 8
    AND p.cvecanc IS NULL
    AND p.fecha BETWEEN fecha1 AND fecha2
    AND c.tipo = 'L'
  GROUP BY p.recaud
  ORDER BY p.recaud;
END;
$$ LANGUAGE plpgsql;