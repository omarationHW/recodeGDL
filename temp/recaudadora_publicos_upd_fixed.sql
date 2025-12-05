-- ================================================================
-- SP: recaudadora_publicos_upd (CORREGIDO)
-- Módulo: multas_reglamentos
-- Descripción: Actualización masiva de conceptos públicos (c_conceptos)
-- Parámetros:
--   p_datos: JSON array con los registros a actualizar/insertar
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_publicos_upd(TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_publicos_upd(
    p_datos TEXT
)
RETURNS TABLE (
    cveconcepto INTEGER,
    descripcion TEXT,
    ncorto TEXT,
    cvegrupo SMALLINT,
    accion TEXT,
    resultado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_json_array JSONB;
    v_record JSONB;
    v_cveconcepto INTEGER;
    v_descripcion VARCHAR(35);
    v_ncorto VARCHAR(15);
    v_cvegrupo SMALLINT;
    v_exists BOOLEAN;
    v_count INTEGER := 0;
BEGIN
    -- Validar y convertir JSON
    BEGIN
        v_json_array := p_datos::JSONB;
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            NULL::INTEGER,
            'ERROR'::TEXT,
            'JSON inválido'::TEXT,
            NULL::SMALLINT,
            'ERROR'::TEXT,
            'El formato JSON no es válido'::TEXT;
        RETURN;
    END;

    -- Validar que sea un array
    IF jsonb_typeof(v_json_array) <> 'array' THEN
        RETURN QUERY
        SELECT
            NULL::INTEGER,
            'ERROR'::TEXT,
            'Debe ser array'::TEXT,
            NULL::SMALLINT,
            'ERROR'::TEXT,
            'El JSON debe ser un array de objetos'::TEXT;
        RETURN;
    END IF;

    -- Procesar cada registro del array
    FOR v_record IN SELECT * FROM jsonb_array_elements(v_json_array)
    LOOP
        -- Extraer valores
        v_cveconcepto := COALESCE((v_record->>'cveconcepto')::INTEGER, 0);
        v_descripcion := UPPER(TRIM(COALESCE(v_record->>'descripcion', '')));
        v_ncorto := UPPER(TRIM(COALESCE(v_record->>'ncorto', '')));
        v_cvegrupo := COALESCE((v_record->>'cvegrupo')::SMALLINT, 1);

        -- Validar datos requeridos
        IF v_descripcion = '' THEN
            RETURN QUERY
            SELECT
                v_cveconcepto,
                'ERROR'::TEXT,
                v_ncorto::TEXT,
                v_cvegrupo,
                'ERROR'::TEXT,
                'Descripción requerida'::TEXT;
            CONTINUE;
        END IF;

        -- Verificar si existe el registro
        SELECT EXISTS(
            SELECT 1 FROM public.c_conceptos c WHERE c.cveconcepto = v_cveconcepto
        ) INTO v_exists;

        IF v_exists THEN
            -- ACTUALIZAR registro existente
            UPDATE public.c_conceptos c
            SET
                descripcion = v_descripcion,
                ncorto = CASE WHEN v_ncorto <> '' THEN v_ncorto ELSE c.ncorto END,
                cvegrupo = v_cvegrupo,
                feccap = CURRENT_DATE,
                capturista = 'SISTEMA'
            WHERE c.cveconcepto = v_cveconcepto;

            v_count := v_count + 1;

            RETURN QUERY
            SELECT
                v_cveconcepto,
                v_descripcion::TEXT,
                v_ncorto::TEXT,
                v_cvegrupo,
                'ACTUALIZADO'::TEXT,
                'Registro actualizado correctamente'::TEXT;
        ELSE
            -- INSERTAR nuevo registro
            IF v_cveconcepto = 0 THEN
                -- Generar clave automática
                SELECT COALESCE(MAX(c.cveconcepto), 0) + 1
                INTO v_cveconcepto
                FROM public.c_conceptos c;
            END IF;

            IF v_ncorto = '' THEN
                v_ncorto := SUBSTRING(v_descripcion, 1, 15);
            END IF;

            INSERT INTO public.c_conceptos (
                cveconcepto,
                descripcion,
                ncorto,
                feccap,
                capturista,
                cvegrupo
            ) VALUES (
                v_cveconcepto,
                v_descripcion,
                v_ncorto,
                CURRENT_DATE,
                'SISTEMA',
                v_cvegrupo
            );

            v_count := v_count + 1;

            RETURN QUERY
            SELECT
                v_cveconcepto,
                v_descripcion::TEXT,
                v_ncorto::TEXT,
                v_cvegrupo,
                'INSERTADO'::TEXT,
                'Registro creado correctamente'::TEXT;
        END IF;
    END LOOP;

    -- Mensaje resumen si no hubo registros procesados
    IF v_count = 0 THEN
        RETURN QUERY
        SELECT
            NULL::INTEGER,
            'INFO'::TEXT,
            'Sin cambios'::TEXT,
            NULL::SMALLINT,
            'INFO'::TEXT,
            'No se procesaron registros'::TEXT;
    END IF;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_publicos_upd(TEXT) IS 'Actualización masiva de conceptos públicos (c_conceptos)';
