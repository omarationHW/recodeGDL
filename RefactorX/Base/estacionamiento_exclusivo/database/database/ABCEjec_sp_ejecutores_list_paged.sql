-- ============================================
-- Stored Procedure: sp_ejecutores_list_paged
-- Tipo: Catalog con paginación
-- Descripción: Lista ejecutores con filtros de búsqueda y paginación
-- Formulario: ABCEjec
-- Fecha: 2025-12-05
-- ============================================

CREATE OR REPLACE FUNCTION sp_ejecutores_list_paged(
    p_q VARCHAR DEFAULT '',
    p_vigencia CHAR(1) DEFAULT NULL,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    ini_rfc VARCHAR(4),
    fec_rfc DATE,
    hom_rfc VARCHAR(3),
    nombre VARCHAR(60),
    id_rec SMALLINT,
    oficio VARCHAR(14),
    fecinic DATE,
    fecterm DATE,
    vigencia CHAR(1),
    categoria VARCHAR(50),
    comision NUMERIC,
    observacion TEXT,
    total_count BIGINT
) AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Contar total de registros que coinciden
    SELECT COUNT(*) INTO v_total
    FROM ta_15_ejecutores e
    WHERE (p_q IS NULL OR p_q = '' OR
           UPPER(e.nombre) LIKE '%' || UPPER(p_q) || '%' OR
           CAST(e.cve_eje AS VARCHAR) LIKE '%' || p_q || '%')
      AND (p_vigencia IS NULL OR p_vigencia = '' OR e.vigencia = p_vigencia);

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        e.cve_eje AS id_ejecutor,
        e.cve_eje,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.nombre,
        e.id_rec,
        e.oficio,
        e.fecinic,
        e.fecterm,
        e.vigencia,
        CASE
            WHEN e.vigencia = 'V' THEN 'Activo'
            WHEN e.vigencia = 'A' THEN 'Activo'
            ELSE 'Inactivo'
        END::VARCHAR(50) AS categoria,
        COALESCE(0, 0)::NUMERIC AS comision,
        ''::TEXT AS observacion,
        v_total
    FROM ta_15_ejecutores e
    WHERE (p_q IS NULL OR p_q = '' OR
           UPPER(e.nombre) LIKE '%' || UPPER(p_q) || '%' OR
           CAST(e.cve_eje AS VARCHAR) LIKE '%' || p_q || '%')
      AND (p_vigencia IS NULL OR p_vigencia = '' OR e.vigencia = p_vigencia)
    ORDER BY e.cve_eje
    OFFSET p_offset
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP para estadísticas de ejecutores
-- ============================================
CREATE OR REPLACE FUNCTION sp_ejecutores_estadisticas()
RETURNS TABLE (
    categoria VARCHAR(50),
    descripcion VARCHAR(100),
    total INTEGER,
    porcentaje NUMERIC,
    clase VARCHAR(20)
) AS $$
DECLARE
    v_total INTEGER;
    v_vigentes INTEGER;
    v_no_vigentes INTEGER;
    v_con_oficio INTEGER;
    v_sin_oficio INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM ta_15_ejecutores;
    SELECT COUNT(*) INTO v_vigentes FROM ta_15_ejecutores WHERE vigencia IN ('V', 'A');
    SELECT COUNT(*) INTO v_no_vigentes FROM ta_15_ejecutores WHERE vigencia NOT IN ('V', 'A') OR vigencia IS NULL;
    SELECT COUNT(*) INTO v_con_oficio FROM ta_15_ejecutores WHERE oficio IS NOT NULL AND oficio != '';
    SELECT COUNT(*) INTO v_sin_oficio FROM ta_15_ejecutores WHERE oficio IS NULL OR oficio = '';

    -- Evitar división por cero
    IF v_total = 0 THEN v_total := 1; END IF;

    RETURN QUERY SELECT
        'TOTAL'::VARCHAR(50),
        'Total de Ejecutores'::VARCHAR(100),
        v_total,
        100.0::NUMERIC,
        'primary'::VARCHAR(20);

    RETURN QUERY SELECT
        'VIGENTES'::VARCHAR(50),
        'Ejecutores Vigentes'::VARCHAR(100),
        v_vigentes,
        ROUND((v_vigentes::NUMERIC / v_total) * 100, 1),
        'success'::VARCHAR(20);

    RETURN QUERY SELECT
        'NO_VIGENTES'::VARCHAR(50),
        'Ejecutores No Vigentes'::VARCHAR(100),
        v_no_vigentes,
        ROUND((v_no_vigentes::NUMERIC / v_total) * 100, 1),
        'danger'::VARCHAR(20);

    RETURN QUERY SELECT
        'CON_OFICIO'::VARCHAR(50),
        'Con Oficio Asignado'::VARCHAR(100),
        v_con_oficio,
        ROUND((v_con_oficio::NUMERIC / v_total) * 100, 1),
        'info'::VARCHAR(20);

    RETURN QUERY SELECT
        'SIN_OFICIO'::VARCHAR(50),
        'Sin Oficio Asignado'::VARCHAR(100),
        v_sin_oficio,
        ROUND((v_sin_oficio::NUMERIC / v_total) * 100, 1),
        'warning'::VARCHAR(20);
END;
$$ LANGUAGE plpgsql;
