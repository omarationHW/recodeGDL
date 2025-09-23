-- Stored Procedure: sp_rep_estadisticos_pagos_lic_rango
-- Tipo: Report
-- Descripción: Reporte de pagos de licencias en un rango de fechas, agrupados por recaudadora.
-- Generado para formulario: repEstadisticosLicfrm
-- Fecha: 2025-08-27 19:20:47

CREATE OR REPLACE FUNCTION sp_rep_estadisticos_pagos_lic_rango(fecha1 DATE, fecha2 DATE)
RETURNS TABLE(
    recaud INTEGER,
    cuantos INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.recaud,
        COUNT(*) AS cuantos
    FROM pagos p
    JOIN licencias l ON l.id_licencia = p.cvecuenta
    JOIN c_giros c ON c.id_giro = l.id_giro
    WHERE p.cveconcepto = 8
      AND p.cvecanc IS NULL
      AND c.tipo = 'L'
      AND p.fecha BETWEEN fecha1 AND fecha2
    GROUP BY p.recaud
    ORDER BY p.recaud;
END;
$$ LANGUAGE plpgsql;