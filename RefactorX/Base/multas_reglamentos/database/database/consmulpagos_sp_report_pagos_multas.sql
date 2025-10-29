-- Stored Procedure: sp_report_pagos_multas
-- Tipo: Report
-- Descripción: Reporte de pagos de multas agrupados por fecha.
-- Generado para formulario: consmulpagos
-- Fecha: 2025-08-26 23:30:27

CREATE OR REPLACE FUNCTION sp_report_pagos_multas(p_fecha_ini date, p_fecha_fin date)
RETURNS TABLE(
    fecha date,
    total_pagos integer,
    total_importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.fecha, COUNT(*) as total_pagos, SUM(p.importe) as total_importe
    FROM pagos p
    WHERE p.cveconcepto = 6
      AND p.fecha BETWEEN p_fecha_ini AND p_fecha_fin
    GROUP BY p.fecha
    ORDER BY p.fecha DESC;
END;
$$ LANGUAGE plpgsql;