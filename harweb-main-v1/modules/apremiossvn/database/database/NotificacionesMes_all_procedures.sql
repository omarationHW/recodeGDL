-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: NotificacionesMes
-- Generado: 2025-08-27 15:22:46
-- Total SPs: 1
-- ============================================

-- SP 1/1: spd_15_notif_mes
-- Tipo: Report
-- Descripción: Reporte de notificaciones por mes, agrupando por módulo, mes, año, ejecutor, y mostrando asignados, practicados, cancelados, pagados y recaudado.
-- --------------------------------------------

-- PostgreSQL version of spd_15_notif_mes
CREATE OR REPLACE FUNCTION spd_15_notif_mes(
    p_axo_pract INTEGER,
    p_axo_emi INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE (
    modulo TEXT,
    mes INTEGER,
    axo INTEGER,
    ejecutor INTEGER,
    asignados INTEGER,
    practicados INTEGER,
    cancelados INTEGER,
    pagados INTEGER,
    recaudado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.modulo::TEXT,
        EXTRACT(MONTH FROM a.fecha_emision)::INTEGER AS mes,
        EXTRACT(YEAR FROM a.fecha_emision)::INTEGER AS axo,
        a.ejecutor,
        COUNT(*) FILTER (WHERE a.vigencia = '1') AS asignados,
        COUNT(*) FILTER (WHERE a.clave_practicado = 'P') AS practicados,
        COUNT(*) FILTER (WHERE a.vigencia = '3') AS cancelados,
        COUNT(*) FILTER (WHERE a.vigencia = '2') AS pagados,
        COALESCE(SUM(CASE WHEN a.vigencia = '2' THEN a.importe_pago ELSE 0 END),0) AS recaudado
    FROM ta_15_apremios a
    WHERE
        EXTRACT(YEAR FROM a.fecha_practicado) = p_axo_pract
        AND EXTRACT(YEAR FROM a.fecha_emision) = p_axo_emi
        AND a.fecha_pago BETWEEN p_fecha_desde AND p_fecha_hasta
    GROUP BY a.modulo, mes, axo, a.ejecutor
    ORDER BY a.modulo, axo, mes, a.ejecutor;
END;
$$ LANGUAGE plpgsql;


-- ============================================

