-- Actualización del Stored Procedure para regHfrm.vue
-- Usando tabla h_multasnvo (histórico de multas)

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_reghfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_reghfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para regHfrm (registro histórico)
CREATE OR REPLACE FUNCTION publico.recaudadora_reghfrm(
    p_params VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa INTEGER,
    id_dependencia INTEGER,
    num_acta VARCHAR,
    axo_acta INTEGER,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    num_licencia VARCHAR,
    giro VARCHAR,
    calificacion NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_tipo VARCHAR;
    v_id_multa INTEGER;
    v_id_dependencia INTEGER;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_axo_acta INTEGER;
    v_limite INTEGER;
    v_params_json JSON;
BEGIN
    -- Parsear parámetros JSON si vienen en formato JSON
    -- Si viene vacío o no es JSON, usar valores por defecto
    BEGIN
        IF p_params IS NOT NULL AND p_params != '' THEN
            v_params_json := p_params::JSON;
            v_tipo := COALESCE((v_params_json->>'tipo')::VARCHAR, 'all');
            v_id_multa := (v_params_json->>'id_multa')::INTEGER;
            v_id_dependencia := (v_params_json->>'id_dependencia')::INTEGER;
            v_fecha_inicio := (v_params_json->>'fecha_inicio')::DATE;
            v_fecha_fin := (v_params_json->>'fecha_fin')::DATE;
            v_axo_acta := (v_params_json->>'axo_acta')::INTEGER;
            v_limite := COALESCE((v_params_json->>'limite')::INTEGER, 100);
        ELSE
            v_tipo := 'all';
            v_limite := 100;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- Si no es JSON, usar valores por defecto
        v_tipo := 'all';
        v_limite := 100;
    END;

    -- Usamos tabla h_multasnvo (histórico de multas)
    RETURN QUERY
    SELECT
        r.id_multa,
        r.id_dependencia::INTEGER,
        r.num_acta::VARCHAR,
        r.axo_acta::INTEGER,
        r.fecha_acta,
        COALESCE(r.contribuyente, 'Sin nombre')::VARCHAR,
        COALESCE(r.domicilio, 'Sin domicilio')::VARCHAR,
        COALESCE(r.num_licencia::VARCHAR, 'N/A')::VARCHAR,
        COALESCE(r.giro, 'Sin giro')::VARCHAR,
        COALESCE(r.calificacion, 0) AS calificacion
    FROM public.h_multasnvo r
    WHERE
        CASE
            WHEN v_tipo = 'id' AND v_id_multa IS NOT NULL THEN
                r.id_multa = v_id_multa
            WHEN v_tipo = 'dependencia' AND v_id_dependencia IS NOT NULL THEN
                r.id_dependencia = v_id_dependencia
                AND (v_fecha_inicio IS NULL OR r.fecha_acta >= v_fecha_inicio)
                AND (v_fecha_fin IS NULL OR r.fecha_acta <= v_fecha_fin)
            ELSE
                (v_fecha_inicio IS NULL OR r.fecha_acta >= v_fecha_inicio)
                AND (v_fecha_fin IS NULL OR r.fecha_acta <= v_fecha_fin)
        END
        AND (v_axo_acta IS NULL OR r.axo_acta = v_axo_acta)
    ORDER BY r.fecha_acta DESC NULLS LAST, r.id_multa DESC
    LIMIT v_limite;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_reghfrm -> Retorna registro histórico usando tabla h_multasnvo
--
-- TABLA BASE: public.h_multasnvo (626,583 registros de multas históricas)
--
-- CAMPOS MAPEADOS (mapeo 1:1):
-- - id_multa -> id_multa (ID único de la multa)
-- - id_dependencia -> id_dependencia (ID de la dependencia)
-- - num_acta -> num_acta (número de acta)
-- - axo_acta -> axo_acta (año del acta)
-- - fecha_acta -> fecha_acta (fecha del acta)
-- - contribuyente -> contribuyente (nombre del contribuyente)
-- - domicilio -> domicilio (domicilio)
-- - num_licencia -> num_licencia (número de licencia)
-- - giro -> giro (giro comercial)
-- - calificacion -> calificacion (monto de calificación)
--
-- PARÁMETROS (JSON):
-- - tipo: 'id' | 'dependencia' | 'all' (tipo de búsqueda)
-- - id_multa: INTEGER (buscar por ID específico)
-- - id_dependencia: INTEGER (buscar por dependencia)
-- - fecha_inicio: DATE (fecha inicio)
-- - fecha_fin: DATE (fecha fin)
-- - axo_acta: INTEGER (año del acta)
-- - limite: INTEGER (límite de registros, default 100)
--
-- ESTADÍSTICAS:
-- - Total registros: 626,583
-- - Años disponibles: 2015-2025 (mayoría)
-- - Dependencias: 7 (304K), 5 (104K), 3 (100K), etc.
-- - 2024: 26,302 registros
-- - 2023: 33,901 registros
-- - 2025: 16,807 registros (hasta la fecha)
--
-- EJEMPLOS DE USO:
--
-- 1. Buscar por ID de multa:
-- SELECT * FROM publico.recaudadora_reghfrm('{"tipo":"id","id_multa":411374}');
--
-- 2. Buscar por dependencia y rango de fechas:
-- SELECT * FROM publico.recaudadora_reghfrm('{"tipo":"dependencia","id_dependencia":3,"fecha_inicio":"2024-01-01","fecha_fin":"2024-12-31"}');
--
-- 3. Buscar por año:
-- SELECT * FROM publico.recaudadora_reghfrm('{"axo_acta":2024,"limite":50}');
--
-- 4. Buscar por rango de fechas:
-- SELECT * FROM publico.recaudadora_reghfrm('{"fecha_inicio":"2024-01-01","fecha_fin":"2024-12-31"}');
--
-- 5. Buscar todos (últimos 100):
-- SELECT * FROM publico.recaudadora_reghfrm('');
