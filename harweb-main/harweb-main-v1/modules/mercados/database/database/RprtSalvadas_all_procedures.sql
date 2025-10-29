-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RprtSalvadas
-- Generado: 2025-08-27 00:35:14
-- Total SPs: 1
-- ============================================

-- SP 1/1: report_salvadas
-- Tipo: Report
-- Descripción: Genera el reporte de salvadas entre dos fechas. Devuelve fecha, descripción y valor.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION report_salvadas(start_date DATE, end_date DATE)
RETURNS TABLE(fecha DATE, descripcion TEXT, valor NUMERIC) AS $$
BEGIN
    -- Ejemplo: Reemplazar por la lógica real de negocio
    RETURN QUERY
    SELECT s.fecha, s.descripcion, s.valor
    FROM salvadas s
    WHERE s.fecha BETWEEN start_date AND end_date
    ORDER BY s.fecha ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

