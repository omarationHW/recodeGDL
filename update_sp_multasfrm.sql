-- Actualización del Stored Procedure para multasfrm.vue
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
        WHERE proname = 'recaudadora_multasfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_multasfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para multasfrm
CREATE OR REPLACE FUNCTION publico.recaudadora_multasfrm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa INTEGER,
    folio VARCHAR,
    anio INTEGER,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    giro VARCHAR,
    licencia VARCHAR,
    total NUMERIC,
    estatus VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta::VARCHAR AS folio,
        m.axo_acta::INTEGER AS anio,
        m.fecha_acta,
        m.contribuyente::VARCHAR,
        m.domicilio::VARCHAR,
        m.giro::VARCHAR,
        COALESCE(m.num_licencia::TEXT, '')::VARCHAR AS licencia,
        COALESCE(m.total, 0)::NUMERIC AS total,
        CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'Cancelada'
            ELSE 'Activa'
        END::VARCHAR AS estatus
    FROM publico.multas m
    WHERE
        CASE
            WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
            ELSE (
                m.num_acta::TEXT ILIKE '%' || p_filtro || '%'
                OR m.contribuyente ILIKE '%' || p_filtro || '%'
                OR m.domicilio ILIKE '%' || p_filtro || '%'
                OR m.giro ILIKE '%' || p_filtro || '%'
                OR m.num_licencia::TEXT ILIKE '%' || p_filtro || '%'
            )
        END
    ORDER BY m.fecha_acta DESC, m.id_multa DESC
    LIMIT 100;

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
-- contribuyente → contribuyente (nombre del contribuyente)
-- domicilio → domicilio (domicilio del contribuyente)
-- giro → giro (giro comercial)
-- licencia → num_licencia (número de licencia)
-- total → total (total = multa + gastos)
-- estatus → derivado de fecha_cancelacion (Activa/Cancelada)
--
-- BÚSQUEDA MULTI-CAMPO:
-- El filtro p_filtro busca en 5 campos simultáneamente:
-- 1. folio (num_acta)
-- 2. contribuyente
-- 3. domicilio
-- 4. giro
-- 5. licencia (num_licencia)
--
-- IMPORTANTE:
-- - Búsqueda con ILIKE (case-insensitive)
-- - Límite de 100 registros para optimizar rendimiento
-- - Estado derivado de fecha_cancelacion (NULL = Activa)
-- - Ordenamiento: fecha más reciente primero
--
-- ESTADÍSTICAS:
-- Total multas: 416,928
-- Multas activas: 409,177 (98.1%)
-- Multas canceladas: 7,751 (1.9%)
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_multasfrm('');  -- Todas (100 más recientes)
-- SELECT * FROM publico.recaudadora_multasfrm('GARCIA');  -- Buscar por contribuyente
-- SELECT * FROM publico.recaudadora_multasfrm('1234');  -- Buscar por folio
-- SELECT * FROM publico.recaudadora_multasfrm('COMERCIO');  -- Buscar por giro
