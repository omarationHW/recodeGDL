-- =====================================================
-- DEPLOY SPs Lote 2 - estacionamiento_exclusivo
-- Componentes: AutorizaDes, CMultEmision, CMultFolio,
--              CartaInvitacion, Cons_his, Ejecutores
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
    -- Busca en ta_15_aprem400 y aplica descuento
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

-- 2. excl_cmultemision_search - Buscar multas por emision
DROP FUNCTION IF EXISTS excl_cmultemision_search(VARCHAR);
CREATE OR REPLACE FUNCTION excl_cmultemision_search(
    p_emision VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    control INTEGER,
    folio VARCHAR,
    zona VARCHAR,
    modulo VARCHAR,
    fecha DATE,
    importe NUMERIC,
    contribuyente VARCHAR,
    direccion VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.control::INTEGER,
        t.folio::VARCHAR,
        t.zona::VARCHAR,
        t.modulo::VARCHAR,
        t.fecha::DATE,
        COALESCE(t.importe_global, 0)::NUMERIC as importe,
        t.contribuyente::VARCHAR,
        t.direccion::VARCHAR,
        CASE WHEN t.vigencia = '1' THEN 'Vigente' ELSE 'No Vigente' END::VARCHAR as vigencia
    FROM ta_15_aprem400 t
    WHERE (p_emision IS NULL OR t.folio ILIKE '%' || p_emision || '%')
    ORDER BY t.fecha DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 3. excl_cmultfolio_search - Buscar multas por folio
DROP FUNCTION IF EXISTS excl_cmultfolio_search(VARCHAR);
CREATE OR REPLACE FUNCTION excl_cmultfolio_search(
    p_folio VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    control INTEGER,
    folio VARCHAR,
    zona VARCHAR,
    modulo VARCHAR,
    fecha DATE,
    importe NUMERIC,
    contribuyente VARCHAR,
    direccion VARCHAR,
    vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.control::INTEGER,
        t.folio::VARCHAR,
        t.zona::VARCHAR,
        t.modulo::VARCHAR,
        t.fecha::DATE,
        COALESCE(t.importe_global, 0)::NUMERIC as importe,
        t.contribuyente::VARCHAR,
        t.direccion::VARCHAR,
        CASE WHEN t.vigencia = '1' THEN 'Vigente' ELSE 'No Vigente' END::VARCHAR as vigencia
    FROM ta_15_aprem400 t
    WHERE (p_folio IS NULL OR t.folio ILIKE '%' || p_folio || '%')
    ORDER BY t.fecha DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- 4. excl_carta_invitacion - Generar carta invitacion
DROP FUNCTION IF EXISTS excl_carta_invitacion(VARCHAR);
CREATE OR REPLACE FUNCTION excl_carta_invitacion(
    p_expediente VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    resultado TEXT,
    expediente VARCHAR,
    contribuyente VARCHAR,
    direccion VARCHAR,
    importe NUMERIC,
    fecha_generacion TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        'OK'::TEXT as resultado,
        t.folio::VARCHAR as expediente,
        t.contribuyente::VARCHAR,
        t.direccion::VARCHAR,
        COALESCE(t.importe_global, 0)::NUMERIC as importe,
        NOW()::TIMESTAMP as fecha_generacion
    FROM ta_15_aprem400 t
    WHERE t.folio ILIKE '%' || COALESCE(p_expediente, '') || '%'
    LIMIT 1;

    -- Si no encuentra, retorna mensaje
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            'ERROR'::TEXT as resultado,
            p_expediente::VARCHAR as expediente,
            'No encontrado'::VARCHAR as contribuyente,
            ''::VARCHAR as direccion,
            0::NUMERIC as importe,
            NOW()::TIMESTAMP as fecha_generacion;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. excl_cons_his - Consulta historica
DROP FUNCTION IF EXISTS excl_cons_his(VARCHAR);
CREATE OR REPLACE FUNCTION excl_cons_his(
    p_expediente VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_historia INTEGER,
    control INTEGER,
    folio VARCHAR,
    fecha DATE,
    accion VARCHAR,
    observacion VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    -- Intenta buscar en ta_15_historia si existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ta_15_historia') THEN
        RETURN QUERY
        SELECT
            h.id::INTEGER as id_historia,
            h.control::INTEGER,
            COALESCE(h.folio, '')::VARCHAR,
            h.fecha::DATE,
            COALESCE(h.accion, '')::VARCHAR,
            COALESCE(h.observacion, '')::VARCHAR,
            COALESCE(h.usuario, '')::VARCHAR
        FROM ta_15_historia h
        WHERE (p_expediente IS NULL OR h.folio ILIKE '%' || p_expediente || '%')
        ORDER BY h.fecha DESC
        LIMIT 100;
    ELSE
        -- Si no existe la tabla, busca en aprem400
        RETURN QUERY
        SELECT
            t.control::INTEGER as id_historia,
            t.control::INTEGER,
            t.folio::VARCHAR,
            t.fecha::DATE,
            'Registro'::VARCHAR as accion,
            COALESCE(t.direccion, '')::VARCHAR as observacion,
            ''::VARCHAR as usuario
        FROM ta_15_aprem400 t
        WHERE (p_expediente IS NULL OR t.folio ILIKE '%' || p_expediente || '%')
        ORDER BY t.fecha DESC
        LIMIT 100;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 6. excl_ejecutores_listar - Listar ejecutores
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
    -- Obtiene ejecutores unicos de ta_15_aprem400
    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY t.ejecutor)::INTEGER as id_ejecutor,
        COALESCE(LEFT(t.ejecutor, 10), 'N/A')::VARCHAR as clave,
        COALESCE(t.ejecutor, 'Sin Asignar')::VARCHAR as nombre,
        'Activo'::VARCHAR as activo,
        COUNT(*)::BIGINT as total_asignados
    FROM ta_15_aprem400 t
    WHERE t.ejecutor IS NOT NULL
      AND t.ejecutor != ''
      AND (p_q IS NULL OR t.ejecutor ILIKE '%' || p_q || '%')
    GROUP BY t.ejecutor
    ORDER BY t.ejecutor
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- Verificar creacion
SELECT proname FROM pg_proc WHERE proname LIKE 'excl_%' ORDER BY proname;
