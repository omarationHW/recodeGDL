-- =====================================================
-- SPs COMPLETOS para ABCEjec - Catálogo de Ejecutores
-- Base: padron_licencias
-- Esquema: comun
-- Tabla: comun.ta_15_ejecutores
-- Fecha: 2025-12-05
-- =====================================================

-- Conectar a la base de datos
\c padron_licencias;
SET search_path TO comun, public;

-- =====================================================
-- 1. SP para listar ejecutores con paginación y filtros
-- =====================================================
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
    oficio CHARACTER VARYING,
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
        e.ini_rfc::CHARACTER(4),
        e.fec_rfc,
        e.hom_rfc::CHARACTER(3),
        e.nombre::CHARACTER VARYING,
        e.id_rec,
        e.categoria::CHARACTER VARYING,
        e.observacion::CHARACTER VARYING,
        e.oficio::CHARACTER VARYING,
        e.fecinic,
        e.fecterm,
        e.vigencia::CHARACTER(1),
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

-- =====================================================
-- 2. SP para obtener un ejecutor específico
-- =====================================================
DROP FUNCTION IF EXISTS comun.sp_ejecutor_get(INTEGER, INTEGER);
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_get(
    p_cve_eje INTEGER,
    p_id_rec INTEGER
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
    oficio CHARACTER VARYING,
    fecinic DATE,
    fecterm DATE,
    vigencia CHARACTER(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_ejecutor,
        e.cve_eje,
        e.ini_rfc::CHARACTER(4),
        e.fec_rfc,
        e.hom_rfc::CHARACTER(3),
        e.nombre::CHARACTER VARYING,
        e.id_rec,
        e.categoria::CHARACTER VARYING,
        e.observacion::CHARACTER VARYING,
        e.oficio::CHARACTER VARYING,
        e.fecinic,
        e.fecterm,
        e.vigencia::CHARACTER(1)
    FROM comun.ta_15_ejecutores e
    WHERE e.cve_eje = p_cve_eje
      AND (p_id_rec IS NULL OR e.id_rec = p_id_rec);
END;
$$;

-- =====================================================
-- 3. SP para crear un nuevo ejecutor
-- =====================================================
DROP FUNCTION IF EXISTS comun.sp_ejecutor_create(INTEGER, CHARACTER VARYING, DATE, CHARACTER VARYING, CHARACTER VARYING, SMALLINT, CHARACTER VARYING, DATE, DATE);
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_create(
    p_cve_eje INTEGER,
    p_ini_rfc CHARACTER VARYING,
    p_fec_rfc DATE,
    p_hom_rfc CHARACTER VARYING,
    p_nombre CHARACTER VARYING,
    p_id_rec SMALLINT,
    p_oficio CHARACTER VARYING,
    p_fecinic DATE,
    p_fecterm DATE
)
RETURNS TABLE(result TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
    v_new_id INTEGER;
BEGIN
    -- Verificar si ya existe
    SELECT COUNT(*) INTO v_existe
    FROM comun.ta_15_ejecutores
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;

    IF v_existe > 0 THEN
        RETURN QUERY SELECT 'Ya existe ejecutor con ese número en la recaudadora'::TEXT;
        RETURN;
    END IF;

    -- Obtener el siguiente id_ejecutor
    SELECT COALESCE(MAX(id_ejecutor), 0) + 1 INTO v_new_id FROM comun.ta_15_ejecutores;

    -- Insertar nuevo ejecutor
    INSERT INTO comun.ta_15_ejecutores (
        id_ejecutor, cve_eje, ini_rfc, fec_rfc, hom_rfc, nombre, id_rec,
        oficio, fecinic, fecterm, vigencia
    ) VALUES (
        v_new_id, p_cve_eje, p_ini_rfc, p_fec_rfc, p_hom_rfc, p_nombre, p_id_rec,
        p_oficio, p_fecinic, p_fecterm, 'A'
    );

    RETURN QUERY SELECT 'OK'::TEXT;
END;
$$;

-- =====================================================
-- 4. SP para actualizar un ejecutor
-- =====================================================
DROP FUNCTION IF EXISTS comun.sp_ejecutor_update(INTEGER, SMALLINT, CHARACTER VARYING, DATE, CHARACTER VARYING, CHARACTER VARYING, CHARACTER VARYING, DATE, DATE);
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_update(
    p_cve_eje INTEGER,
    p_id_rec SMALLINT,
    p_ini_rfc CHARACTER VARYING,
    p_fec_rfc DATE,
    p_hom_rfc CHARACTER VARYING,
    p_nombre CHARACTER VARYING,
    p_oficio CHARACTER VARYING,
    p_fecinic DATE,
    p_fecterm DATE
)
RETURNS TABLE(result TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE comun.ta_15_ejecutores
    SET
        ini_rfc = p_ini_rfc,
        fec_rfc = p_fec_rfc,
        hom_rfc = p_hom_rfc,
        nombre = p_nombre,
        oficio = p_oficio,
        fecinic = p_fecinic,
        fecterm = p_fecterm,
        vigencia = 'A'
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;

    IF FOUND THEN
        RETURN QUERY SELECT 'OK'::TEXT;
    ELSE
        RETURN QUERY SELECT 'No existe ejecutor con esa clave'::TEXT;
    END IF;
END;
$$;

-- =====================================================
-- 5. SP para cambiar vigencia (Baja/Reactiva)
-- =====================================================
DROP FUNCTION IF EXISTS comun.sp_ejecutor_toggle_vigencia(INTEGER, SMALLINT);
CREATE OR REPLACE FUNCTION comun.sp_ejecutor_toggle_vigencia(
    p_cve_eje INTEGER,
    p_id_rec SMALLINT
)
RETURNS TABLE(result TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_vigencia_actual CHARACTER(1);
BEGIN
    -- Obtener vigencia actual
    SELECT vigencia INTO v_vigencia_actual
    FROM comun.ta_15_ejecutores
    WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'No existe ejecutor con esa clave'::TEXT;
        RETURN;
    END IF;

    -- Toggle vigencia
    IF v_vigencia_actual = 'A' OR v_vigencia_actual = 'V' THEN
        UPDATE comun.ta_15_ejecutores
        SET vigencia = 'B'
        WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
        RETURN QUERY SELECT 'Baja'::TEXT;
    ELSE
        UPDATE comun.ta_15_ejecutores
        SET vigencia = 'A'
        WHERE cve_eje = p_cve_eje AND id_rec = p_id_rec;
        RETURN QUERY SELECT 'Reactivado'::TEXT;
    END IF;
END;
$$;

-- =====================================================
-- 6. SP para listar recaudadoras
-- =====================================================
DROP FUNCTION IF EXISTS comun.sp_recaudadoras_list();
CREATE OR REPLACE FUNCTION comun.sp_recaudadoras_list()
RETURNS TABLE(
    id_rec SMALLINT,
    id_zona INTEGER,
    recaudadora CHARACTER VARYING,
    domicilio CHARACTER VARYING,
    tel CHARACTER VARYING,
    recaudador CHARACTER VARYING,
    sector CHARACTER VARYING
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id_rec,
        r.id_zona,
        r.recaudadora::CHARACTER VARYING,
        r.domicilio::CHARACTER VARYING,
        r.tel::CHARACTER VARYING,
        r.recaudador::CHARACTER VARYING,
        r.sector::CHARACTER VARYING
    FROM comun.ta_12_recaudadoras r
    ORDER BY r.id_rec;
END;
$$;

-- =====================================================
-- 7. SP para estadísticas de ejecutores
-- =====================================================
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
    SELECT COUNT(*)::INTEGER INTO v_total_general
    FROM comun.ta_15_ejecutores;

    SELECT COUNT(*)::INTEGER INTO v_total_vigentes
    FROM comun.ta_15_ejecutores
    WHERE vigencia IN ('V', 'A');

    SELECT COUNT(*)::INTEGER INTO v_total_no_vigentes
    FROM comun.ta_15_ejecutores
    WHERE vigencia NOT IN ('V', 'A') OR vigencia IS NULL;

    SELECT COUNT(*)::INTEGER INTO v_total_con_oficio
    FROM comun.ta_15_ejecutores
    WHERE oficio IS NOT NULL AND TRIM(oficio) <> '';

    SELECT COUNT(*)::INTEGER INTO v_total_sin_oficio
    FROM comun.ta_15_ejecutores
    WHERE oficio IS NULL OR TRIM(oficio) = '';

    -- Evitar división por cero
    IF v_total_general = 0 THEN
        v_total_general := 1;
    END IF;

    -- Retornar estadísticas
    RETURN QUERY
    SELECT
        'TOTAL'::CHARACTER VARYING,
        'Total de Ejecutores'::CHARACTER VARYING,
        v_total_general,
        100.00::NUMERIC,
        'default'::CHARACTER VARYING;

    RETURN QUERY
    SELECT
        'VIGENTES'::CHARACTER VARYING,
        'Ejecutores Vigentes'::CHARACTER VARYING,
        v_total_vigentes,
        ROUND((v_total_vigentes::NUMERIC / v_total_general * 100), 2),
        'success'::CHARACTER VARYING;

    RETURN QUERY
    SELECT
        'NO_VIGENTES'::CHARACTER VARYING,
        'No Vigentes / Sin Status'::CHARACTER VARYING,
        v_total_no_vigentes,
        ROUND((v_total_no_vigentes::NUMERIC / v_total_general * 100), 2),
        'warning'::CHARACTER VARYING;

    RETURN QUERY
    SELECT
        'CON_OFICIO'::CHARACTER VARYING,
        'Con Oficio Asignado'::CHARACTER VARYING,
        v_total_con_oficio,
        ROUND((v_total_con_oficio::NUMERIC / v_total_general * 100), 2),
        'info'::CHARACTER VARYING;

    RETURN QUERY
    SELECT
        'SIN_OFICIO'::CHARACTER VARYING,
        'Sin Oficio'::CHARACTER VARYING,
        v_total_sin_oficio,
        ROUND((v_total_sin_oficio::NUMERIC / v_total_general * 100), 2),
        'danger'::CHARACTER VARYING;

    RETURN;
END;
$$;

-- =====================================================
-- Mensaje de confirmación
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'SPs para ABCEjec creados exitosamente en comun:';
    RAISE NOTICE '  - comun.sp_ejecutores_list';
    RAISE NOTICE '  - comun.sp_ejecutor_get';
    RAISE NOTICE '  - comun.sp_ejecutor_create';
    RAISE NOTICE '  - comun.sp_ejecutor_update';
    RAISE NOTICE '  - comun.sp_ejecutor_toggle_vigencia';
    RAISE NOTICE '  - comun.sp_recaudadoras_list';
    RAISE NOTICE '  - comun.sp_ejecutores_estadisticas';
    RAISE NOTICE '=====================================================';
END $$;
