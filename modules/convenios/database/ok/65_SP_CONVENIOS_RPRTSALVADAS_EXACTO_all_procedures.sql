-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPRTSALVADAS (EXACTO del archivo original)
-- Archivo: 65_SP_CONVENIOS_RPRTSALVADAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
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

