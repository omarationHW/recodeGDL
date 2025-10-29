-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: FRMPOL (EXACTO del archivo original)
-- Archivo: 96_SP_RECAUDADORA_FRMPOL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: reporte_poliza_por_recaudadora
-- Tipo: Report
-- Descripción: Genera el reporte de póliza por recaudadora para una fecha y recaudadora específica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION reporte_poliza_por_recaudadora(p_fecha DATE, p_recaud VARCHAR)
RETURNS TABLE(
    cvectaapl VARCHAR,
    ctaaplicacion VARCHAR,
    totpar INTEGER,
    suma NUMERIC(18,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cvectaapl, c.ctaaplicacion, COUNT(*) AS totpar, SUM(a.monto) AS suma
    FROM pagos p
    JOIN auditoria a ON p.cvepago = a.cvepago
    JOIN c_ctasapl c ON a.cvectaapl = c.cvectaapl
    WHERE p.recaud = p_recaud
      AND p.fecha = p_fecha
      AND a.cancelacion = 'N'
    GROUP BY a.cvectaapl, c.ctaaplicacion
    ORDER BY a.cvectaapl;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: FRMPOL (EXACTO del archivo original)
-- Archivo: 96_SP_RECAUDADORA_FRMPOL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

