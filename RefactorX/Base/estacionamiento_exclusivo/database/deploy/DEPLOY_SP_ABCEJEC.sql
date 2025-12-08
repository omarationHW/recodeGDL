-- =====================================================
-- SPs para ABCEjec - Catálogo de Ejecutores
-- Base: padron_licencias (tabla en comun.ta_15_ejecutores)
-- Fecha: 2025-11-26
-- =====================================================

-- 1. SP para listar ejecutores con paginación y filtros
DROP FUNCTION IF EXISTS comun.sp_ejecutores_list(CHARACTER VARYING, CHARACTER VARYING, INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION comun.sp_ejecutores_list(
    p_q CHARACTER VARYING DEFAULT NULL,
    p_vigencia CHARACTER VARYING DEFAULT NULL,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc CHARACTER(4),
    fec_rfc DATE,
    hom_rfc CHARACTER(3),
    nombre CHARACTER VARYING,
    id_rec SMALLINT,
    categoria CHARACTER VARYING,
    observacion CHARACTER VARYING,
    oficio CHARACTER(10),
    fecinic DATE,
    fecterm DATE,
    vigencia CHARACTER(1),
    comision NUMERIC,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Contar total para paginación
    SELECT COUNT(*) INTO v_total
    FROM comun.ta_15_ejecutores e
    WHERE (p_q IS NULL OR p_q = '' OR
           UPPER(e.nombre) LIKE '%' || UPPER(p_q) || '%' OR
           e.cve_eje::TEXT LIKE '%' || p_q || '%')
      AND (p_vigencia IS NULL OR p_vigencia = '' OR e.vigencia = p_vigencia);

    RETURN QUERY
    SELECT
        e.id_ejecutor,
        e.cve_eje,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.nombre,
        e.id_rec,
        e.categoria,
        e.observacion,
        e.oficio,
        e.fecinic,
        e.fecterm,
        e.vigencia,
        0::NUMERIC AS comision,
        v_total
    FROM comun.ta_15_ejecutores e
    WHERE (p_q IS NULL OR p_q = '' OR
           UPPER(e.nombre) LIKE '%' || UPPER(p_q) || '%' OR
           e.cve_eje::TEXT LIKE '%' || p_q || '%')
      AND (p_vigencia IS NULL OR p_vigencia = '' OR e.vigencia = p_vigencia)
    ORDER BY e.cve_eje
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

-- 2. SP para estadísticas de ejecutores
DROP FUNCTION IF EXISTS comun.sp_ejecutores_estadisticas();
CREATE OR REPLACE FUNCTION comun.sp_ejecutores_estadisticas()
RETURNS TABLE(
    categoria CHARACTER VARYING,
    descripcion CHARACTER VARYING,
    total INTEGER,
    porcentaje NUMERIC,
    clase CHARACTER VARYING
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_general INTEGER;
    v_total_vigentes INTEGER;
    v_total_no_vigentes INTEGER;
    v_total_con_oficio INTEGER;
    v_total_sin_oficio INTEGER;
BEGIN
    -- Obtener totales
    SELECT COUNT(*) INTO v_total_general
    FROM comun.ta_15_ejecutores;

    SELECT COUNT(*) INTO v_total_vigentes
    FROM comun.ta_15_ejecutores
    WHERE vigencia = 'V';

    SELECT COUNT(*) INTO v_total_no_vigentes
    FROM comun.ta_15_ejecutores
    WHERE vigencia <> 'V' OR vigencia IS NULL;

    SELECT COUNT(*) INTO v_total_con_oficio
    FROM comun.ta_15_ejecutores
    WHERE oficio IS NOT NULL AND TRIM(oficio) <> '';

    SELECT COUNT(*) INTO v_total_sin_oficio
    FROM comun.ta_15_ejecutores
    WHERE oficio IS NULL OR TRIM(oficio) = '';

    -- Evitar división por cero
    IF v_total_general = 0 THEN
        v_total_general := 1;
    END IF;

    -- Retornar estadísticas
    RETURN QUERY
    SELECT
        'TOTAL'::VARCHAR,
        'Total de Ejecutores'::VARCHAR,
        v_total_general,
        100.00::NUMERIC,
        'default'::VARCHAR;

    RETURN QUERY
    SELECT
        'VIGENTES'::VARCHAR,
        'Ejecutores Vigentes'::VARCHAR,
        v_total_vigentes,
        ROUND((v_total_vigentes::NUMERIC / v_total_general * 100), 2),
        'success'::VARCHAR;

    RETURN QUERY
    SELECT
        'NO_VIGENTES'::VARCHAR,
        'No Vigentes / Sin Status'::VARCHAR,
        v_total_no_vigentes,
        ROUND((v_total_no_vigentes::NUMERIC / v_total_general * 100), 2),
        'warning'::VARCHAR;

    RETURN QUERY
    SELECT
        'CON_OFICIO'::VARCHAR,
        'Con Oficio Asignado'::VARCHAR,
        v_total_con_oficio,
        ROUND((v_total_con_oficio::NUMERIC / v_total_general * 100), 2),
        'info'::VARCHAR;

    RETURN QUERY
    SELECT
        'SIN_OFICIO'::VARCHAR,
        'Sin Oficio'::VARCHAR,
        v_total_sin_oficio,
        ROUND((v_total_sin_oficio::NUMERIC / v_total_general * 100), 2),
        'danger'::VARCHAR;

    RETURN;
END;
$$;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'SPs para ABCEjec creados exitosamente en schema comun';
END $$;
