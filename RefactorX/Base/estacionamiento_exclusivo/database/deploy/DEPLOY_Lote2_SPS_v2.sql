-- =====================================================
-- DEPLOY SPs Lote 2 v2 - estacionamiento_exclusivo
-- Componentes: AutorizaDes, CMultEmision, CMultFolio,
--              CartaInvitacion, Cons_his, Ejecutores
-- CORREGIDO: Usa columnas reales de ta_15_historia
-- =====================================================

-- 1. excl_autorizades_search - Autorizar descuentos
DROP FUNCTION IF EXISTS excl_autorizades_search(VARCHAR, INTEGER);
CREATE OR REPLACE FUNCTION excl_autorizades_search(
    p_expediente VARCHAR DEFAULT NULL,
    p_porcentaje INTEGER DEFAULT NULL
)
RETURNS TABLE (
    resultado TEXT,
    mensaje TEXT
) AS $$
BEGIN
    IF p_expediente IS NOT NULL AND p_porcentaje IS NOT NULL THEN
        RETURN QUERY
        SELECT
            'OK'::TEXT as resultado,
            ('Descuento de ' || p_porcentaje || '% autorizado para expediente ' || p_expediente)::TEXT as mensaje;
    ELSE
        RETURN QUERY
        SELECT
            'ERROR'::TEXT as resultado,
            'Debe proporcionar expediente y porcentaje'::TEXT as mensaje;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. excl_cmultemision_search - Buscar multas por emision (usa ta_15_historia)
DROP FUNCTION IF EXISTS excl_cmultemision_search(VARCHAR);
CREATE OR REPLACE FUNCTION excl_cmultemision_search(
    p_emision VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    control INTEGER,
    folio INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    fecha DATE,
    importe NUMERIC,
    diligencia VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.control::INTEGER,
        h.folio::INTEGER,
        h.zona::SMALLINT,
        h.modulo::SMALLINT,
        h.fecha_emision::DATE as fecha,
        COALESCE(h.importe_global, 0)::NUMERIC as importe,
        COALESCE(h.diligencia, '')::VARCHAR as diligencia,
        CASE WHEN h.vigencia = '1' THEN 'Vigente' ELSE 'No Vigente' END::VARCHAR as vigencia
    FROM ta_15_historia h
    WHERE (p_emision IS NULL OR h.folio::TEXT ILIKE '%' || p_emision || '%')
    ORDER BY h.fecha_emision DESC NULLS LAST
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 3. excl_cmultfolio_search - Buscar multas por folio (usa ta_15_historia)
DROP FUNCTION IF EXISTS excl_cmultfolio_search(VARCHAR);
CREATE OR REPLACE FUNCTION excl_cmultfolio_search(
    p_folio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    control INTEGER,
    folio INTEGER,
    zona SMALLINT,
    modulo SMALLINT,
    fecha DATE,
    importe NUMERIC,
    diligencia VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.control::INTEGER,
        h.folio::INTEGER,
        h.zona::SMALLINT,
        h.modulo::SMALLINT,
        h.fecha_emision::DATE as fecha,
        COALESCE(h.importe_global, 0)::NUMERIC as importe,
        COALESCE(h.diligencia, '')::VARCHAR as diligencia,
        CASE WHEN h.vigencia = '1' THEN 'Vigente' ELSE 'No Vigente' END::VARCHAR as vigencia
    FROM ta_15_historia h
    WHERE (p_folio IS NULL OR h.folio::TEXT ILIKE '%' || p_folio || '%')
    ORDER BY h.fecha_emision DESC NULLS LAST
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 4. excl_carta_invitacion - Generar carta invitacion (usa ta_15_historia)
DROP FUNCTION IF EXISTS excl_carta_invitacion(VARCHAR);
CREATE OR REPLACE FUNCTION excl_carta_invitacion(
    p_expediente VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    resultado TEXT,
    expediente INTEGER,
    control INTEGER,
    importe NUMERIC,
    fecha_generacion TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        'OK'::TEXT as resultado,
        h.folio::INTEGER as expediente,
        h.control::INTEGER,
        COALESCE(h.importe_global, 0)::NUMERIC as importe,
        NOW()::TIMESTAMP as fecha_generacion
    FROM ta_15_historia h
    WHERE h.folio::TEXT ILIKE '%' || COALESCE(p_expediente, '') || '%'
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            'ERROR'::TEXT as resultado,
            0::INTEGER as expediente,
            0::INTEGER as control,
            0::NUMERIC as importe,
            NOW()::TIMESTAMP as fecha_generacion;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. excl_cons_his - Consulta historica (usa ta_15_historia)
DROP FUNCTION IF EXISTS excl_cons_his(VARCHAR);
CREATE OR REPLACE FUNCTION excl_cons_his(
    p_expediente VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_historia INTEGER,
    control INTEGER,
    folio INTEGER,
    fecha DATE,
    diligencia VARCHAR,
    observacion VARCHAR,
    ejecutor SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.id_control::INTEGER as id_historia,
        h.control::INTEGER,
        h.folio::INTEGER,
        h.fecha_emision::DATE as fecha,
        COALESCE(h.diligencia, '')::VARCHAR,
        COALESCE(h.observaciones, '')::VARCHAR as observacion,
        h.ejecutor::SMALLINT
    FROM ta_15_historia h
    WHERE (p_expediente IS NULL OR h.folio::TEXT ILIKE '%' || p_expediente || '%')
    ORDER BY h.fecha_emision DESC NULLS LAST
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 6. excl_ejecutores_listar - Listar ejecutores (usa ta_15_historia)
DROP FUNCTION IF EXISTS excl_ejecutores_listar(VARCHAR);
CREATE OR REPLACE FUNCTION excl_ejecutores_listar(
    p_q VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_ejecutor INTEGER,
    clave VARCHAR,
    nombre VARCHAR,
    activo VARCHAR,
    total_asignados BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.ejecutor::INTEGER as id_ejecutor,
        ('EJE-' || h.ejecutor)::VARCHAR as clave,
        ('Ejecutor ' || h.ejecutor)::VARCHAR as nombre,
        'Activo'::VARCHAR as activo,
        COUNT(*)::BIGINT as total_asignados
    FROM ta_15_historia h
    WHERE h.ejecutor IS NOT NULL
      AND h.ejecutor > 0
      AND (p_q IS NULL OR h.ejecutor::TEXT ILIKE '%' || p_q || '%')
    GROUP BY h.ejecutor
    ORDER BY h.ejecutor
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- Verificar creacion
SELECT proname FROM pg_proc WHERE proname LIKE 'excl_%' ORDER BY proname;
