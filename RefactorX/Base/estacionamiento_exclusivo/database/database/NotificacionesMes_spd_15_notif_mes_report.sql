-- =====================================================
-- SP: spd_15_notif_mes_report
-- Descripción: Notificaciones agrupadas por mes y año
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION spd_15_notif_mes_report(
    p_mes INTEGER,
    p_anio INTEGER
)
RETURNS TABLE (
    mes VARCHAR(20),
    total_notificaciones INTEGER,
    total_acuses INTEGER,
    total_pendientes INTEGER,
    porcentaje_acuses NUMERIC(5,2)
) AS $$
BEGIN
    RETURN QUERY
    WITH notif_data AS (
        SELECT
            EXTRACT(MONTH FROM fecha_practicado) AS mes_num,
            COUNT(*) AS total_notif,
            COUNT(CASE WHEN fecha_entrega1 IS NOT NULL THEN 1 END) AS total_acuse
        FROM ta_15_apremios
        WHERE EXTRACT(MONTH FROM fecha_practicado) = p_mes
          AND EXTRACT(YEAR FROM fecha_practicado) = p_anio
          AND fecha_practicado IS NOT NULL
        GROUP BY EXTRACT(MONTH FROM fecha_practicado)
    )
    SELECT
        TO_CHAR(TO_DATE(p_mes::TEXT, 'MM'), 'Month')::VARCHAR(20) AS mes,
        COALESCE(nd.total_notif, 0)::INTEGER AS total_notificaciones,
        COALESCE(nd.total_acuse, 0)::INTEGER AS total_acuses,
        COALESCE(nd.total_notif - nd.total_acuse, 0)::INTEGER AS total_pendientes,
        CASE
            WHEN nd.total_notif > 0 THEN
                ROUND((nd.total_acuse::NUMERIC / nd.total_notif * 100), 2)
            ELSE 0
        END AS porcentaje_acuses
    FROM notif_data nd;

    -- Si no hay datos, retornar zeros
    IF NOT FOUND THEN
        RETURN QUERY SELECT
            TO_CHAR(TO_DATE(p_mes::TEXT, 'MM'), 'Month')::VARCHAR(20),
            0::INTEGER,
            0::INTEGER,
            0::INTEGER,
            0::NUMERIC(5,2);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM spd_15_notif_mes_report(1, 2025);
-- SELECT * FROM spd_15_notif_mes_report(6, 2025);
