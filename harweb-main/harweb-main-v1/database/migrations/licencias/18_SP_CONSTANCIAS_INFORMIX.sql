-- =====================================================
-- SP_CONSTANCIAS_INFORMIX.sql
-- Stored Procedures para módulo de Constancias
-- Compatibilidad: INFORMIX -> PostgreSQL
-- Fecha: 2025-01-29
-- =====================================================

-- Establecer esquema de trabajo
SET search_path TO informix, public;

-- =====================================================
-- SP: sp_constancia_list
-- Descripción: Lista todas las constancias con paginación y filtros
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_list(
    p_limite INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0,
    p_solicita VARCHAR(100) DEFAULT '',
    p_folio VARCHAR(20) DEFAULT '',
    p_partidapago VARCHAR(30) DEFAULT ''
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(100),
    partidapago VARCHAR(30),
    domicilio VARCHAR(150),
    tipo INTEGER,
    observacion VARCHAR(200),
    vigente CHAR(1),
    feccap TIMESTAMP,
    capturista VARCHAR(50),
    total_registros BIGINT
) AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Calcular total de registros
    SELECT COUNT(*) INTO v_total
    FROM constancias c
    WHERE (p_solicita = '' OR UPPER(c.solicita) LIKE '%' || UPPER(p_solicita) || '%')
      AND (p_folio = '' OR CAST(c.folio AS VARCHAR) LIKE '%' || p_folio || '%')
      AND (p_partidapago = '' OR UPPER(COALESCE(c.partidapago, '')) LIKE '%' || UPPER(p_partidapago) || '%');

    -- Retornar resultados paginados
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        c.id_licencia,
        c.solicita,
        c.partidapago,
        c.domicilio,
        c.tipo,
        c.observacion,
        c.vigente,
        c.feccap,
        c.capturista,
        v_total as total_registros
    FROM constancias c
    WHERE (p_solicita = '' OR UPPER(c.solicita) LIKE '%' || UPPER(p_solicita) || '%')
      AND (p_folio = '' OR CAST(c.folio AS VARCHAR) LIKE '%' || p_folio || '%')
      AND (p_partidapago = '' OR UPPER(COALESCE(c.partidapago, '')) LIKE '%' || UPPER(p_partidapago) || '%')
    ORDER BY c.feccap DESC, c.folio DESC
    LIMIT p_limite OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: sp_constancia_detalle
-- Descripción: Obtiene el detalle de una constancia específica
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_detalle(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    id_licencia INTEGER,
    solicita VARCHAR(100),
    partidapago VARCHAR(30),
    domicilio VARCHAR(150),
    tipo INTEGER,
    observacion VARCHAR(200),
    vigente CHAR(1),
    feccap TIMESTAMP,
    capturista VARCHAR(50),
    -- Datos relacionados de la licencia
    nombre_establecimiento VARCHAR(150),
    giro VARCHAR(100),
    direccion_licencia VARCHAR(200)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.axo,
        c.folio,
        c.id_licencia,
        c.solicita,
        c.partidapago,
        c.domicilio,
        c.tipo,
        c.observacion,
        c.vigente,
        c.feccap,
        c.capturista,
        -- Datos de la licencia relacionada
        COALESCE(l.nombre, '') as nombre_establecimiento,
        COALESCE(l.giro, '') as giro,
        COALESCE(l.domicilio, '') as direccion_licencia
    FROM constancias c
    LEFT JOIN licencias l ON c.id_licencia = l.id_licencia
    WHERE c.axo = p_axo AND c.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: sp_constancia_insert
-- Descripción: Inserta una nueva constancia
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_insert(
    p_id_licencia INTEGER,
    p_solicita VARCHAR(100),
    p_partidapago VARCHAR(30) DEFAULT '',
    p_domicilio VARCHAR(150) DEFAULT '',
    p_tipo INTEGER DEFAULT NULL,
    p_observacion VARCHAR(200) DEFAULT '',
    p_vigente CHAR(1) DEFAULT 'V'
)
RETURNS TABLE(
    resultado VARCHAR(10),
    mensaje VARCHAR(200),
    axo INTEGER,
    folio INTEGER
) AS $$
DECLARE
    v_axo INTEGER;
    v_folio INTEGER;
    v_usuario VARCHAR(50) := 'SISTEMA';
    v_exists INTEGER;
BEGIN
    -- Validaciones
    IF p_id_licencia IS NULL OR p_id_licencia <= 0 THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'ID de licencia inválido'::VARCHAR, 0::INTEGER, 0::INTEGER;
        RETURN;
    END IF;

    IF p_solicita IS NULL OR TRIM(p_solicita) = '' THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'El nombre del solicitante es obligatorio'::VARCHAR, 0::INTEGER, 0::INTEGER;
        RETURN;
    END IF;

    -- Verificar que existe la licencia
    SELECT COUNT(*) INTO v_exists FROM licencias WHERE id_licencia = p_id_licencia;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'La licencia especificada no existe'::VARCHAR, 0::INTEGER, 0::INTEGER;
        RETURN;
    END IF;

    -- Obtener año actual
    v_axo := EXTRACT(YEAR FROM CURRENT_DATE);

    -- Obtener siguiente folio
    SELECT COALESCE(MAX(folio), 0) + 1 INTO v_folio
    FROM constancias
    WHERE axo = v_axo;

    -- Insertar constancia
    INSERT INTO constancias (
        axo, folio, id_licencia, solicita, partidapago,
        domicilio, tipo, observacion, vigente, feccap, capturista
    ) VALUES (
        v_axo, v_folio, p_id_licencia, TRIM(p_solicita),
        COALESCE(TRIM(p_partidapago), ''),
        COALESCE(TRIM(p_domicilio), ''), p_tipo,
        COALESCE(TRIM(p_observacion), ''), p_vigente,
        CURRENT_TIMESTAMP, v_usuario
    );

    RETURN QUERY SELECT 'SUCCESS'::VARCHAR, 'Constancia creada exitosamente'::VARCHAR, v_axo, v_folio;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'ERROR'::VARCHAR, 'Error al crear constancia: ' || SQLERRM::VARCHAR, 0::INTEGER, 0::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: sp_constancia_update
-- Descripción: Actualiza una constancia existente
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita VARCHAR(100),
    p_partidapago VARCHAR(30) DEFAULT '',
    p_domicilio VARCHAR(150) DEFAULT '',
    p_tipo INTEGER DEFAULT NULL,
    p_observacion VARCHAR(200) DEFAULT '',
    p_vigente CHAR(1) DEFAULT 'V'
)
RETURNS TABLE(
    resultado VARCHAR(10),
    mensaje VARCHAR(200)
) AS $$
DECLARE
    v_exists INTEGER;
    v_licencia_exists INTEGER;
    v_usuario VARCHAR(50) := 'SISTEMA';
BEGIN
    -- Validaciones
    IF p_axo IS NULL OR p_folio IS NULL THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'Año y folio son obligatorios'::VARCHAR;
        RETURN;
    END IF;

    IF p_id_licencia IS NULL OR p_id_licencia <= 0 THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'ID de licencia inválido'::VARCHAR;
        RETURN;
    END IF;

    IF p_solicita IS NULL OR TRIM(p_solicita) = '' THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'El nombre del solicitante es obligatorio'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar que existe la constancia
    SELECT COUNT(*) INTO v_exists
    FROM constancias
    WHERE axo = p_axo AND folio = p_folio;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'La constancia especificada no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar que existe la licencia
    SELECT COUNT(*) INTO v_licencia_exists FROM licencias WHERE id_licencia = p_id_licencia;
    IF v_licencia_exists = 0 THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'La licencia especificada no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar constancia
    UPDATE constancias SET
        id_licencia = p_id_licencia,
        solicita = TRIM(p_solicita),
        partidapago = COALESCE(TRIM(p_partidapago), ''),
        domicilio = COALESCE(TRIM(p_domicilio), ''),
        tipo = p_tipo,
        observacion = COALESCE(TRIM(p_observacion), ''),
        vigente = p_vigente,
        capturista = v_usuario
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT 'SUCCESS'::VARCHAR, 'Constancia actualizada exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'ERROR'::VARCHAR, 'Error al actualizar constancia: ' || SQLERRM::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: sp_constancia_delete
-- Descripción: Elimina una constancia (marca como cancelada)
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_delete(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    resultado VARCHAR(10),
    mensaje VARCHAR(200)
) AS $$
DECLARE
    v_exists INTEGER;
    v_usuario VARCHAR(50) := 'SISTEMA';
BEGIN
    -- Validaciones
    IF p_axo IS NULL OR p_folio IS NULL THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'Año y folio son obligatorios'::VARCHAR;
        RETURN;
    END IF;

    -- Verificar que existe la constancia
    SELECT COUNT(*) INTO v_exists
    FROM constancias
    WHERE axo = p_axo AND folio = p_folio;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'ERROR'::VARCHAR, 'La constancia especificada no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Marcar como cancelada en lugar de eliminar físicamente
    UPDATE constancias SET
        vigente = 'C',
        observacion = COALESCE(observacion, '') || ' [CANCELADA: ' || CURRENT_DATE || ']',
        capturista = v_usuario
    WHERE axo = p_axo AND folio = p_folio;

    RETURN QUERY SELECT 'SUCCESS'::VARCHAR, 'Constancia cancelada exitosamente'::VARCHAR;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT 'ERROR'::VARCHAR, 'Error al cancelar constancia: ' || SQLERRM::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: sp_constancia_print
-- Descripción: Obtiene datos para impresión de constancia
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_print(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    -- Datos de la constancia
    axo INTEGER,
    folio INTEGER,
    solicita VARCHAR(100),
    partidapago VARCHAR(30),
    domicilio VARCHAR(150),
    tipo INTEGER,
    tipo_descripcion VARCHAR(50),
    observacion VARCHAR(200),
    vigente CHAR(1),
    vigente_descripcion VARCHAR(20),
    feccap TIMESTAMP,
    feccap_formato VARCHAR(50),
    capturista VARCHAR(50),
    -- Datos de la licencia
    id_licencia INTEGER,
    nombre_establecimiento VARCHAR(150),
    giro VARCHAR(100),
    direccion_licencia VARCHAR(200),
    telefono VARCHAR(20),
    rfc VARCHAR(20),
    -- Datos municipales
    municipio VARCHAR(100),
    fecha_impresion VARCHAR(50),
    folio_completo VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        -- Datos de la constancia
        c.axo,
        c.folio,
        c.solicita,
        c.partidapago,
        c.domicilio,
        c.tipo,
        CASE
            WHEN c.tipo = 1 THEN 'Constancia de No Adeudo'
            WHEN c.tipo = 2 THEN 'Constancia de Vigencia'
            WHEN c.tipo = 3 THEN 'Constancia General'
            ELSE 'Sin especificar'
        END as tipo_descripcion,
        c.observacion,
        c.vigente,
        CASE c.vigente
            WHEN 'V' THEN 'Vigente'
            WHEN 'C' THEN 'Cancelada'
            ELSE 'Indefinido'
        END as vigente_descripcion,
        c.feccap,
        TO_CHAR(c.feccap, 'DD "de" TMMonth "de" YYYY "a las" HH24:MI') as feccap_formato,
        c.capturista,
        -- Datos de la licencia
        c.id_licencia,
        COALESCE(l.nombre, 'NO ESPECIFICADO') as nombre_establecimiento,
        COALESCE(l.giro, 'NO ESPECIFICADO') as giro,
        COALESCE(l.domicilio, 'NO ESPECIFICADO') as direccion_licencia,
        COALESCE(l.telefono, '') as telefono,
        COALESCE(l.rfc, '') as rfc,
        -- Datos municipales
        'Guadalajara, Jalisco'::VARCHAR as municipio,
        TO_CHAR(CURRENT_TIMESTAMP, 'DD "de" TMMonth "de" YYYY "a las" HH24:MI') as fecha_impresion,
        (c.axo::VARCHAR || '-' || LPAD(c.folio::VARCHAR, 6, '0')) as folio_completo
    FROM constancias c
    LEFT JOIN licencias l ON c.id_licencia = l.id_licencia
    WHERE c.axo = p_axo AND c.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SP: sp_constancia_estadisticas
-- Descripción: Obtiene estadísticas del módulo de constancias
-- =====================================================
CREATE OR REPLACE FUNCTION sp_constancia_estadisticas(
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL
)
RETURNS TABLE(
    total_constancias BIGINT,
    constancias_vigentes BIGINT,
    constancias_canceladas BIGINT,
    constancias_mes_actual BIGINT,
    constancias_anio_actual BIGINT,
    tipos_estadisticas JSON,
    constancias_por_mes JSON
) AS $$
DECLARE
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_tipos_json JSON;
    v_meses_json JSON;
BEGIN
    -- Definir rangos de fecha
    v_fecha_inicio := COALESCE(p_fecha_inicio, DATE_TRUNC('year', CURRENT_DATE));
    v_fecha_fin := COALESCE(p_fecha_fin, CURRENT_DATE);

    -- Estadísticas por tipo
    SELECT json_agg(
        json_build_object(
            'tipo', COALESCE(tipo_desc, 'Sin tipo'),
            'cantidad', cantidad
        )
    ) INTO v_tipos_json
    FROM (
        SELECT
            CASE
                WHEN tipo = 1 THEN 'No Adeudo'
                WHEN tipo = 2 THEN 'Vigencia'
                WHEN tipo = 3 THEN 'General'
                ELSE 'Sin especificar'
            END as tipo_desc,
            COUNT(*) as cantidad
        FROM constancias
        WHERE feccap::DATE BETWEEN v_fecha_inicio AND v_fecha_fin
        GROUP BY tipo
        ORDER BY cantidad DESC
    ) tipos;

    -- Estadísticas por mes
    SELECT json_agg(
        json_build_object(
            'mes', mes,
            'cantidad', cantidad
        )
    ) INTO v_meses_json
    FROM (
        SELECT
            TO_CHAR(feccap, 'YYYY-MM') as mes,
            COUNT(*) as cantidad
        FROM constancias
        WHERE feccap::DATE BETWEEN v_fecha_inicio AND v_fecha_fin
        GROUP BY TO_CHAR(feccap, 'YYYY-MM')
        ORDER BY mes
    ) meses;

    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM constancias) as total_constancias,
        (SELECT COUNT(*) FROM constancias WHERE vigente = 'V') as constancias_vigentes,
        (SELECT COUNT(*) FROM constancias WHERE vigente = 'C') as constancias_canceladas,
        (SELECT COUNT(*) FROM constancias WHERE DATE_TRUNC('month', feccap) = DATE_TRUNC('month', CURRENT_DATE)) as constancias_mes_actual,
        (SELECT COUNT(*) FROM constancias WHERE EXTRACT(YEAR FROM feccap) = EXTRACT(YEAR FROM CURRENT_DATE)) as constancias_anio_actual,
        COALESCE(v_tipos_json, '[]'::JSON) as tipos_estadisticas,
        COALESCE(v_meses_json, '[]'::JSON) as constancias_por_mes;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Comentarios y metadatos
-- =====================================================
COMMENT ON FUNCTION sp_constancia_list IS 'Lista constancias con paginación y filtros de búsqueda';
COMMENT ON FUNCTION sp_constancia_detalle IS 'Obtiene el detalle completo de una constancia específica';
COMMENT ON FUNCTION sp_constancia_insert IS 'Crea una nueva constancia con validaciones';
COMMENT ON FUNCTION sp_constancia_update IS 'Actualiza los datos de una constancia existente';
COMMENT ON FUNCTION sp_constancia_delete IS 'Cancela una constancia (soft delete)';
COMMENT ON FUNCTION sp_constancia_print IS 'Obtiene datos formateados para impresión de constancia';
COMMENT ON FUNCTION sp_constancia_estadisticas IS 'Genera estadísticas del módulo de constancias';

-- =====================================================
-- FIN DEL ARCHIVO
-- =====================================================