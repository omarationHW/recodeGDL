-- Actualización del Stored Procedure para MultasDM.vue
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
        WHERE proname = 'recaudadora_multas_dm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_multas_dm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para MultasDM con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_multas_dm(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_ejercicio INTEGER DEFAULT 0,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id_multa INTEGER,
    clave_cuenta VARCHAR,
    folio VARCHAR,
    ejercicio INTEGER,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    id_dependencia SMALLINT,
    expediente VARCHAR,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    fecha_acta DATE,
    fecha_recepcion DATE,
    fecha_cancelacion DATE,
    estado VARCHAR,
    observacion TEXT,
    giro VARCHAR,
    recaud SMALLINT,
    zona SMALLINT,
    subzona SMALLINT,
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
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR (m.num_acta::TEXT || '/' || m.axo_acta::TEXT) ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR m.axo_acta = p_ejercicio);

    -- Retornar registros con paginación
    RETURN QUERY
    SELECT
        m.id_multa,
        (m.num_acta::TEXT || '/' || m.axo_acta::TEXT)::VARCHAR AS clave_cuenta,
        m.num_acta::VARCHAR AS folio,
        m.axo_acta::INTEGER AS ejercicio,
        m.contribuyente::VARCHAR,
        m.domicilio::VARCHAR,
        m.id_dependencia,
        TRIM(COALESCE(m.expediente, ''))::VARCHAR AS expediente,
        COALESCE(m.multa, 0)::NUMERIC AS multa,
        COALESCE(m.gastos, 0)::NUMERIC AS gastos,
        COALESCE(m.total, 0)::NUMERIC AS total,
        m.fecha_acta,
        m.fecha_recepcion,
        m.fecha_cancelacion,
        CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'Cancelada'
            ELSE 'Activa'
        END::VARCHAR AS estado,
        COALESCE(m.observacion, '')::TEXT AS observacion,
        m.giro::VARCHAR,
        m.recaud,
        m.zona,
        m.subzona,
        v_total_count AS total_count
    FROM publico.multas m
    WHERE
        (p_clave_cuenta = '' OR p_clave_cuenta IS NULL OR (m.num_acta::TEXT || '/' || m.axo_acta::TEXT) ILIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR p_ejercicio IS NULL OR m.axo_acta = p_ejercicio)
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
-- clave_cuenta → num_acta || '/' || axo_acta (identificador compuesto)
-- folio → num_acta (número de acta)
-- ejercicio → axo_acta (año de acta)
-- contribuyente → contribuyente (nombre del contribuyente)
-- domicilio → domicilio (domicilio del contribuyente)
-- id_dependencia → id_dependencia (código de dependencia)
-- expediente → expediente (número de expediente, con TRIM)
-- multa → multa (importe de multa)
-- gastos → gastos (gastos de ejecución)
-- total → total (total = multa + gastos)
-- fecha_acta → fecha_acta (fecha del acta)
-- fecha_recepcion → fecha_recepcion (fecha de recepción)
-- fecha_cancelacion → fecha_cancelacion (fecha de cancelación si existe)
-- estado → derivado de fecha_cancelacion (Activa/Cancelada)
-- observacion → observacion (observaciones adicionales)
-- giro → giro (giro comercial)
-- recaud → recaud (recaudadora)
-- zona → zona (zona)
-- subzona → subzona (subzona)
-- total_count → total de registros que cumplen el filtro (para paginación)
--
-- FILTROS:
-- - p_clave_cuenta: Búsqueda en clave_cuenta (num_acta/axo_acta)
-- - p_ejercicio: Filtro por año de acta (0 = todos)
-- - p_offset: Inicio de página para paginación
-- - p_limit: Cantidad de registros por página
--
-- IMPORTANTE:
-- - Paginación con OFFSET y LIMIT
-- - total_count para mostrar paginación en frontend
-- - Estado derivado de fecha_cancelacion (NULL = Activa)
-- - Búsqueda por clave_cuenta usa ILIKE (case-insensitive)
-- - Filtro de ejercicio es exacto (axo_acta = p_ejercicio)
--
-- ESTADÍSTICAS:
-- Total multas: 416,928
-- Multas activas: 409,177 (98.1%)
-- Multas canceladas: 7,751 (1.9%)
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_multas_dm('', 0, 0, 50);  -- Todas, primera página
-- SELECT * FROM publico.recaudadora_multas_dm('1234', 0, 0, 50);  -- Buscar por clave
-- SELECT * FROM publico.recaudadora_multas_dm('', 2025, 0, 50);  -- Solo ejercicio 2025
-- SELECT * FROM publico.recaudadora_multas_dm('', 0, 50, 50);  -- Segunda página
