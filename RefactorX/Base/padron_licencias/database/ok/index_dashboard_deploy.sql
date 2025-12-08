-- ============================================
-- DEPLOY CONSOLIDADO: index (Dashboard Principal)
-- Componente 95/95 - BATCH 19
-- Generado: 2025-11-20
-- Total SPs: 5 (Estadísticas y resúmenes para dashboard)
-- ============================================

-- SP 1/5: sp_dashboard_resumen_licencias
CREATE OR REPLACE FUNCTION public.sp_dashboard_resumen_licencias()
RETURNS JSON AS $$
DECLARE
    v_total INTEGER;
    v_vigentes INTEGER;
    v_suspendidas INTEGER;
    v_canceladas INTEGER;
    v_mes_actual INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM licencias;
    SELECT COUNT(*) INTO v_vigentes FROM licencias WHERE vigente = 'V';
    SELECT COUNT(*) INTO v_suspendidas FROM licencias l JOIN bloqueo b ON b.id_licencia = l.id_licencia WHERE b.vigente = 'V';
    SELECT COUNT(*) INTO v_canceladas FROM licencias WHERE vigente = 'C';
    SELECT COUNT(*) INTO v_mes_actual FROM licencias WHERE vigente = 'V' AND EXTRACT(MONTH FROM fecha_otorgamiento) = EXTRACT(MONTH FROM CURRENT_DATE) AND EXTRACT(YEAR FROM fecha_otorgamiento) = EXTRACT(YEAR FROM CURRENT_DATE);

    RETURN json_build_object(
        'total', v_total,
        'vigentes', v_vigentes,
        'suspendidas', v_suspendidas,
        'canceladas', v_canceladas,
        'mes_actual', v_mes_actual
    );
END;
$$ LANGUAGE plpgsql;

-- SP 2/5: sp_dashboard_resumen_anuncios
CREATE OR REPLACE FUNCTION public.sp_dashboard_resumen_anuncios()
RETURNS JSON AS $$
DECLARE
    v_total INTEGER;
    v_vigentes INTEGER;
    v_cancelados INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM anuncios;
    SELECT COUNT(*) INTO v_vigentes FROM anuncios WHERE vigente = 'V';
    SELECT COUNT(*) INTO v_cancelados FROM anuncios WHERE vigente = 'C';

    RETURN json_build_object(
        'total', v_total,
        'vigentes', v_vigentes,
        'cancelados', v_cancelados
    );
END;
$$ LANGUAGE plpgsql;

-- SP 3/5: sp_dashboard_resumen_tramites
CREATE OR REPLACE FUNCTION public.sp_dashboard_resumen_tramites()
RETURNS JSON AS $$
DECLARE
    v_total INTEGER;
    v_pendientes INTEGER;
    v_en_proceso INTEGER;
    v_completados INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM tramites;
    SELECT COUNT(*) INTO v_pendientes FROM tramites WHERE estatus = 'P';
    SELECT COUNT(*) INTO v_en_proceso FROM tramites WHERE estatus = 'T';
    SELECT COUNT(*) INTO v_completados FROM tramites WHERE estatus = 'C';

    RETURN json_build_object(
        'total', v_total,
        'pendientes', v_pendientes,
        'en_proceso', v_en_proceso,
        'completados', v_completados
    );
END;
$$ LANGUAGE plpgsql;

-- SP 4/5: sp_dashboard_top_giros
CREATE OR REPLACE FUNCTION public.sp_dashboard_top_giros(p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR,
    total INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT l.id_giro, g.descripcion, COUNT(*)::INTEGER AS total
    FROM licencias l
    JOIN c_giros g ON g.id_giro = l.id_giro
    WHERE l.vigente = 'V'
    GROUP BY l.id_giro, g.descripcion
    ORDER BY total DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- SP 5/5: sp_dashboard_licencias_por_mes
CREATE OR REPLACE FUNCTION public.sp_dashboard_licencias_por_mes(p_year INTEGER DEFAULT NULL)
RETURNS TABLE(
    mes INTEGER,
    nombre_mes VARCHAR,
    total INTEGER
) AS $$
DECLARE
    v_year INTEGER;
BEGIN
    v_year := COALESCE(p_year, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    RETURN QUERY
    SELECT
        EXTRACT(MONTH FROM fecha_otorgamiento)::INTEGER AS mes,
        TO_CHAR(fecha_otorgamiento, 'Month')::VARCHAR AS nombre_mes,
        COUNT(*)::INTEGER AS total
    FROM licencias
    WHERE EXTRACT(YEAR FROM fecha_otorgamiento) = v_year AND vigente = 'V'
    GROUP BY mes, nombre_mes
    ORDER BY mes;
END;
$$ LANGUAGE plpgsql;
