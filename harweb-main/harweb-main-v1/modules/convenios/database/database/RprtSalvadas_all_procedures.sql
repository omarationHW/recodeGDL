-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RprtSalvadas
-- Generado: 2025-08-27 15:17:05
-- Total SPs: 1
-- ============================================

-- SP 1/1: rprt_salvadas_report
-- Tipo: Report
-- Descripción: Genera el reporte de salvadas filtrado por usuario y rango de fechas.
-- --------------------------------------------

--
-- PROCEDURE: rprt_salvadas_report(user_id integer, date_from date, date_to date)
--
CREATE OR REPLACE FUNCTION rprt_salvadas_report(
    user_id integer DEFAULT NULL,
    date_from date DEFAULT NULL,
    date_to date DEFAULT NULL
)
RETURNS TABLE(
    user_id integer,
    user_name text,
    saved_at date,
    description text,
    status text
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.user_id,
        u.name AS user_name,
        s.saved_at,
        s.description,
        s.status
    FROM salvadas s
    LEFT JOIN users u ON u.id = s.user_id
    WHERE (user_id IS NULL OR s.user_id = user_id)
      AND (date_from IS NULL OR s.saved_at >= date_from)
      AND (date_to IS NULL OR s.saved_at <= date_to)
    ORDER BY s.saved_at DESC, s.id DESC;
END;
$$ LANGUAGE plpgsql;


-- ============================================

