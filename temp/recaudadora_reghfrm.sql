-- ================================================================
-- SP: recaudadora_reghfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta histórica de registros de multas
-- Parámetros:
--   p_filtros: JSON con filtros de búsqueda histórica
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_reghfrm(TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_reghfrm(
    p_filtros TEXT
)
RETURNS TABLE (
    id_multa INTEGER,
    id_dependencia SMALLINT,
    axo_acta SMALLINT,
    num_acta INTEGER,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    num_licencia INTEGER,
    giro VARCHAR,
    expediente VARCHAR,
    calificacion NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_json JSONB;
    v_tipo VARCHAR(20);
    v_id_multa INTEGER;
    v_fecha_inicio DATE;
    v_fecha_fin DATE;
    v_id_dependencia SMALLINT;
    v_axo_acta SMALLINT;
    v_limite INTEGER;
BEGIN
    -- Validar y convertir JSON
    BEGIN
        v_json := p_filtros::JSONB;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'JSON inválido: %', SQLERRM;
    END;

    -- Extraer parámetros
    v_tipo := COALESCE(v_json->>'tipo', 'rango');
    v_id_multa := (v_json->>'id_multa')::INTEGER;
    v_fecha_inicio := COALESCE((v_json->>'fecha_inicio')::DATE, CURRENT_DATE - INTERVAL '30 days');
    v_fecha_fin := COALESCE((v_json->>'fecha_fin')::DATE, CURRENT_DATE);
    v_id_dependencia := (v_json->>'id_dependencia')::SMALLINT;
    v_axo_acta := (v_json->>'axo_acta')::SMALLINT;
    v_limite := COALESCE((v_json->>'limite')::INTEGER, 20);

    -- Validar límite
    IF v_limite < 1 OR v_limite > 100 THEN
        v_limite := 20;
    END IF;

    -- Búsqueda por tipo
    CASE v_tipo
        WHEN 'id' THEN
            -- Búsqueda por ID específico
            IF v_id_multa IS NULL THEN
                RAISE EXCEPTION 'Se requiere id_multa para búsqueda por ID';
            END IF;

            RETURN QUERY
            SELECT
                m.id_multa,
                m.id_dependencia,
                m.axo_acta,
                m.num_acta,
                m.fecha_acta,
                m.contribuyente::VARCHAR,
                m.domicilio::VARCHAR,
                m.num_licencia,
                m.giro::VARCHAR,
                m.expediente::VARCHAR,
                m.calificacion
            FROM comun.multas m
            WHERE m.id_multa = v_id_multa;

        WHEN 'dependencia' THEN
            -- Búsqueda por dependencia con filtros adicionales
            IF v_id_dependencia IS NULL THEN
                RAISE EXCEPTION 'Se requiere id_dependencia para búsqueda por dependencia';
            END IF;

            RETURN QUERY
            SELECT
                m.id_multa,
                m.id_dependencia,
                m.axo_acta,
                m.num_acta,
                m.fecha_acta,
                m.contribuyente::VARCHAR,
                m.domicilio::VARCHAR,
                m.num_licencia,
                m.giro::VARCHAR,
                m.expediente::VARCHAR,
                m.calificacion
            FROM comun.multas m
            WHERE m.id_dependencia = v_id_dependencia
            AND m.fecha_acta BETWEEN v_fecha_inicio AND v_fecha_fin
            AND (v_axo_acta IS NULL OR m.axo_acta = v_axo_acta)
            ORDER BY m.fecha_acta DESC, m.id_multa DESC
            LIMIT v_limite;

        ELSE
            -- Búsqueda por rango (default) con filtros adicionales
            RETURN QUERY
            SELECT
                m.id_multa,
                m.id_dependencia,
                m.axo_acta,
                m.num_acta,
                m.fecha_acta,
                m.contribuyente::VARCHAR,
                m.domicilio::VARCHAR,
                m.num_licencia,
                m.giro::VARCHAR,
                m.expediente::VARCHAR,
                m.calificacion
            FROM comun.multas m
            WHERE m.fecha_acta BETWEEN v_fecha_inicio AND v_fecha_fin
            AND (v_id_dependencia IS NULL OR m.id_dependencia = v_id_dependencia)
            AND (v_axo_acta IS NULL OR m.axo_acta = v_axo_acta)
            ORDER BY m.id_multa DESC
            LIMIT v_limite;
    END CASE;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_reghfrm(TEXT) IS 'Consulta histórica de registros de multas con múltiples filtros';
