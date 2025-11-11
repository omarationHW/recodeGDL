-- =====================================================
-- SP: sp_estadisticas_generales
-- Descripción: Estadísticas generales de apremios con filtros de fecha
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_estadisticas_generales(
    p_desde DATE,
    p_hasta DATE
)
RETURNS TABLE (
    categoria VARCHAR(100),
    descripcion VARCHAR(255),
    total INTEGER,
    porcentaje NUMERIC(5,2),
    clase VARCHAR(50)
) AS $$
DECLARE
    v_total_general INTEGER;
BEGIN
    -- Obtener total general
    SELECT COUNT(*)::INTEGER INTO v_total_general
    FROM ta_15_apremios
    WHERE fecha_emision BETWEEN p_desde AND p_hasta;

    -- Si no hay registros, retornar vacío
    IF v_total_general = 0 THEN
        RETURN;
    END IF;

    -- Estadísticas por vigencia
    RETURN QUERY
    SELECT
        'VIGENCIA'::VARCHAR(100) AS categoria,
        CASE
            WHEN vigencia = '1' THEN 'Vigente'
            WHEN vigencia = '2' THEN 'Pagado'
            WHEN vigencia = 'P' THEN 'Pagado Parcial'
            WHEN vigencia = '3' THEN 'Cancelado'
            ELSE 'Otros'
        END::VARCHAR(255) AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general * 100), 2) AS porcentaje,
        'info'::VARCHAR(50) AS clase
    FROM ta_15_apremios
    WHERE fecha_emision BETWEEN p_desde AND p_hasta
    GROUP BY vigencia

    UNION ALL

    -- Estadísticas por módulo
    SELECT
        'MODULO'::VARCHAR(100) AS categoria,
        'Módulo ' || COALESCE(modulo::VARCHAR, 'N/A')::VARCHAR(255) AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general * 100), 2) AS porcentaje,
        'success'::VARCHAR(50) AS clase
    FROM ta_15_apremios
    WHERE fecha_emision BETWEEN p_desde AND p_hasta
    GROUP BY modulo

    UNION ALL

    -- Estadísticas de pagos
    SELECT
        'PAGOS'::VARCHAR(100) AS categoria,
        'Con pago registrado'::VARCHAR(255) AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general * 100), 2) AS porcentaje,
        'warning'::VARCHAR(50) AS clase
    FROM ta_15_apremios
    WHERE fecha_emision BETWEEN p_desde AND p_hasta
      AND fecha_pago IS NOT NULL

    UNION ALL

    -- Estadísticas de diligencias
    SELECT
        'DILIGENCIAS'::VARCHAR(100) AS categoria,
        'Diligencias practicadas'::VARCHAR(255) AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general * 100), 2) AS porcentaje,
        'primary'::VARCHAR(50) AS clase
    FROM ta_15_apremios
    WHERE fecha_emision BETWEEN p_desde AND p_hasta
      AND fecha_practicado IS NOT NULL

    ORDER BY categoria, total DESC;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_estadisticas_generales('2025-01-01', '2025-12-31');
-- SELECT * FROM sp_estadisticas_generales('2025-01-01', CURRENT_DATE);
