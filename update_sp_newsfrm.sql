-- Actualización del Stored Procedure para newsfrm.vue
-- Usa la tabla existente: publico.multas

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_newsfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_newsfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para newsfrm con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_newsfrm(
    p_filtro VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id_multa INTEGER,
    folio VARCHAR,
    anio INTEGER,
    fecha_acta DATE,
    fecha_recepcion DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    giro VARCHAR,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    estatus VARCHAR,
    observacion TEXT,
    total_count BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Contar total de registros que cumplen el filtro
    SELECT COUNT(*)
    INTO v_total_count
    FROM publico.multas m
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                m.num_acta::TEXT ILIKE '%' || p_filtro || '%'
                OR m.contribuyente ILIKE '%' || p_filtro || '%'
                OR m.axo_acta::TEXT ILIKE '%' || p_filtro || '%'
            )
        END;

    -- Retornar registros con paginación
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta::VARCHAR AS folio,
        m.axo_acta::INTEGER AS anio,
        m.fecha_acta,
        m.fecha_recepcion,
        m.contribuyente::VARCHAR,
        m.domicilio::VARCHAR,
        m.giro::VARCHAR,
        COALESCE(m.multa, 0)::NUMERIC AS multa,
        COALESCE(m.gastos, 0)::NUMERIC AS gastos,
        COALESCE(m.total, 0)::NUMERIC AS total,
        CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'Cancelada'
            ELSE 'Activa'
        END::VARCHAR AS estatus,
        COALESCE(m.observacion, '')::TEXT AS observacion,
        v_total_count AS total_count
    FROM publico.multas m
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                m.num_acta::TEXT ILIKE '%' || p_filtro || '%'
                OR m.contribuyente ILIKE '%' || p_filtro || '%'
                OR m.axo_acta::TEXT ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY m.fecha_acta DESC, m.id_multa DESC
    OFFSET p_offset
    LIMIT p_limit;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.multas -> Tabla principal de multas
--
-- Mapeo de campos:
-- id_multa → id_multa (identificador único)
-- folio → num_acta (número de acta)
-- anio → axo_acta (año de acta)
-- fecha_acta → fecha_acta (fecha del acta)
-- fecha_recepcion → fecha_recepcion (fecha de recepción)
-- contribuyente → contribuyente (nombre del contribuyente)
-- domicilio → domicilio (domicilio del contribuyente)
-- giro → giro (giro comercial)
-- multa → multa (importe de multa)
-- gastos → gastos (gastos de ejecución)
-- total → total (total = multa + gastos)
-- estatus → derivado de fecha_cancelacion (Activa/Cancelada)
-- observacion → observacion (observaciones adicionales)
-- total_count → total de registros que cumplen el filtro (para paginación)
--
-- BÚSQUEDA:
-- El filtro p_filtro busca en 3 campos:
-- 1. folio (num_acta)
-- 2. contribuyente
-- 3. anio (axo_acta)
--
-- IMPORTANTE:
-- - Búsqueda con ILIKE (case-insensitive)
-- - Paginación con OFFSET y LIMIT
-- - total_count para mostrar paginación en frontend
-- - Estado derivado de fecha_cancelacion (NULL = Activa)
-- - Ordenamiento: fecha más reciente primero (novedades)
--
-- ESTADÍSTICAS:
-- Total multas: 416,928
-- Multas activas: 409,177 (98.1%)
-- Multas canceladas: 7,751 (1.9%)
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_newsfrm('', 0, 50);  -- Primera página
-- SELECT * FROM publico.recaudadora_newsfrm('GARCIA', 0, 50);  -- Buscar por contribuyente
-- SELECT * FROM publico.recaudadora_newsfrm('2025', 0, 50);  -- Buscar por año
-- SELECT * FROM publico.recaudadora_newsfrm('', 50, 50);  -- Segunda página
