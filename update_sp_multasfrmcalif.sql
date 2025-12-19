-- Actualización del Stored Procedure para multasfrmcalif.vue
-- Usa las tablas existentes: publico.multas + publico.tipo_calificacion_multa

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_multasfrmcalif'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_multasfrmcalif(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para multasfrmcalif con paginación
CREATE OR REPLACE FUNCTION publico.recaudadora_multasfrmcalif(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE (
    id_multa INTEGER,
    clave_cuenta VARCHAR,
    folio VARCHAR,
    ejercicio VARCHAR,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    calificacion NUMERIC,
    tipo_calificacion VARCHAR,
    estado VARCHAR,
    fecha_acta DATE,
    fecha_recepcion DATE,
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
            WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
            ELSE (
                (m.num_acta::TEXT || '/' || m.axo_acta::TEXT) ILIKE '%' || p_clave_cuenta || '%'
                OR m.num_acta::TEXT ILIKE '%' || p_clave_cuenta || '%'
                OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
            )
        END;

    -- Retornar registros con paginación
    RETURN QUERY
    SELECT
        m.id_multa,
        (m.num_acta::TEXT || '/' || m.axo_acta::TEXT)::VARCHAR AS clave_cuenta,
        m.num_acta::VARCHAR AS folio,
        m.axo_acta::VARCHAR AS ejercicio,
        m.contribuyente::VARCHAR,
        m.domicilio::VARCHAR,
        COALESCE(m.multa, 0)::NUMERIC AS multa,
        COALESCE(m.gastos, 0)::NUMERIC AS gastos,
        COALESCE(m.total, 0)::NUMERIC AS total,
        COALESCE(m.calificacion, 0)::NUMERIC AS calificacion,
        COALESCE(
            tc.tipo_calificacion::TEXT,
            'N/A'
        )::VARCHAR AS tipo_calificacion,
        CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'Cancelada'
            ELSE 'Activa'
        END::VARCHAR AS estado,
        m.fecha_acta,
        m.fecha_recepcion,
        COALESCE(m.observacion, '')::TEXT AS observacion,
        v_total_count AS total_count
    FROM publico.multas m
    LEFT JOIN publico.tipo_calificacion_multa tc ON m.id_multa = tc.id_multa
    WHERE
        CASE
            WHEN p_clave_cuenta = '' OR p_clave_cuenta IS NULL THEN TRUE
            ELSE (
                (m.num_acta::TEXT || '/' || m.axo_acta::TEXT) ILIKE '%' || p_clave_cuenta || '%'
                OR m.num_acta::TEXT ILIKE '%' || p_clave_cuenta || '%'
                OR m.contribuyente ILIKE '%' || p_clave_cuenta || '%'
            )
        END
    ORDER BY m.fecha_acta DESC, m.id_multa DESC
    OFFSET p_offset
    LIMIT p_limit;

END;
$$;

-- Comentarios sobre el mapeo:
-- publico.multas -> Tabla principal de multas con calificación
-- publico.tipo_calificacion_multa -> Tabla de tipos de calificación (LEFT JOIN)
--
-- Mapeo de campos:
-- id_multa → id_multa (identificador único)
-- clave_cuenta → num_acta || '/' || axo_acta (identificador compuesto)
-- folio → num_acta (número de acta)
-- ejercicio → axo_acta (año de acta)
-- contribuyente → contribuyente (nombre del contribuyente)
-- domicilio → domicilio (domicilio del contribuyente)
-- multa → multa (importe de multa)
-- gastos → gastos (gastos de ejecución)
-- total → total (total = multa + gastos)
-- calificacion → calificacion (NUMERIC, valor de calificación)
-- tipo_calificacion → tipo_calificacion (O=Oficial, M=Manual, N/A=Sin tipo)
-- estado → derivado de fecha_cancelacion (Activa/Cancelada)
-- fecha_acta → fecha_acta (fecha del acta)
-- fecha_recepcion → fecha_recepcion (fecha de recepción)
-- observacion → observacion (observaciones adicionales)
-- total_count → total de registros que cumplen el filtro (para paginación)
--
-- IMPORTANTE:
-- - LEFT JOIN con tipo_calificacion_multa porque solo 2.96% tienen tipo
-- - Búsqueda en 3 campos: clave_cuenta, folio, contribuyente
-- - Paginación con OFFSET y LIMIT
-- - total_count para mostrar paginación en frontend
-- - Estado derivado de fecha_cancelacion (NULL = Activa)
--
-- TIPOS DE CALIFICACIÓN:
-- 'O' = Oficial (7,744 registros)
-- 'M' = Manual (4,582 registros)
-- 'N/A' = Sin tipo asignado (404,602 registros)
--
-- DISTRIBUCIÓN DE CALIFICACIONES:
-- Baja (<= 50k): 410,419 multas
-- Media (50k-100k): 2,593 multas
-- Alta (> 100k): 1,905 multas
-- Cero: 2,004 multas
-- Sin calificación: 7 multas
--
-- ESTADÍSTICAS:
-- Total multas: 416,928
-- Multas con tipo_calificacion: 12,326 (2.96%)
-- Multas activas: Mayoría sin fecha_cancelacion
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_multasfrmcalif('', 0, 50);  -- Primera página
-- SELECT * FROM publico.recaudadora_multasfrmcalif('GARCIA', 0, 50);  -- Buscar por nombre
-- SELECT * FROM publico.recaudadora_multasfrmcalif('1234', 50, 50);  -- Segunda página
