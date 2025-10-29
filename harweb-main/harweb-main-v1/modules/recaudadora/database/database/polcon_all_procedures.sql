-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: polcon
-- Generado: 2025-08-27 14:10:59
-- Total SPs: 1
-- ============================================

-- SP 1/1: report_polcon
-- Tipo: Report
-- Descripción: Reporte de póliza diaria consolidada de las recaudadoras. Devuelve por rango de fechas la cuenta de aplicación, descripción, total de partidas y suma de montos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_polcon(date_from DATE, date_to DATE)
RETURNS TABLE (
    cvectaapl VARCHAR,
    ctaaplicacion VARCHAR,
    totpar INTEGER,
    suma NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.cvectaapl,
        c.ctaaplicacion,
        COUNT(*) AS totpar,
        SUM(a.monto) AS suma
    FROM pagos p
    JOIN auditoria a ON p.cvepago = a.cvepago
    JOIN c_ctasapl c ON a.cvectaapl = c.cvectaapl
    WHERE p.fecha BETWEEN date_from AND date_to
      AND a.cancelacion = 'N'
    GROUP BY a.cvectaapl, c.ctaaplicacion
    ORDER BY a.cvectaapl;
END;
$$ LANGUAGE plpgsql;

-- ============================================

