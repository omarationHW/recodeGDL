-- Actualización del Stored Procedure para ipor.vue
-- Usa tabla public.c_tasas con datos reales en lugar de valores estáticos

DROP FUNCTION IF EXISTS public.ipor_sp_list(jsonb) CASCADE;
DROP FUNCTION IF EXISTS publico.recaudadora_ipor(jsonb) CASCADE;

-- Función principal en schema publico
CREATE OR REPLACE FUNCTION publico.recaudadora_ipor(
    p_datos TEXT
)
RETURNS TABLE (
    id INTEGER,
    concepto VARCHAR,
    porcentaje NUMERIC,
    anio INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_datos JSON;
    v_filtro VARCHAR;
BEGIN
    -- Parsear el JSON de entrada
    BEGIN
        v_datos := p_datos::JSON;
        v_filtro := COALESCE(v_datos->>'filtro', '');
    EXCEPTION
        WHEN OTHERS THEN
            v_filtro := '';
    END;

    -- Buscar en la tabla c_tasas aplicando el filtro
    RETURN QUERY
    SELECT
        t.tasa::INTEGER AS id,
        ('Tasa ' || t.constbald || ' - Año ' || t.axo)::VARCHAR AS concepto,
        ROUND((t.tasaporcen * 100)::NUMERIC, 4) AS porcentaje,
        t.axo::INTEGER AS anio
    FROM public.c_tasas t
    WHERE
        -- Si hay filtro, buscar en concepto generado o en año
        (v_filtro = '' OR
         CAST(t.axo AS TEXT) ILIKE '%' || v_filtro || '%' OR
         t.constbald ILIKE '%' || v_filtro || '%' OR
         CAST(t.tasa AS TEXT) = v_filtro)
    ORDER BY t.axo DESC, t.tasa
    LIMIT 100;

END;
$$;

-- Función alternativa para compatibilidad con JSONB
CREATE OR REPLACE FUNCTION publico.recaudadora_ipor(
    p_params JSONB DEFAULT '{}'::JSONB
)
RETURNS TABLE (
    id INTEGER,
    concepto VARCHAR,
    porcentaje NUMERIC,
    anio INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Extraer filtro del JSONB
    v_filtro := COALESCE(p_params->>'filtro', '');

    -- Buscar en la tabla c_tasas aplicando el filtro
    RETURN QUERY
    SELECT
        t.tasa::INTEGER AS id,
        ('Tasa ' || t.constbald || ' - Año ' || t.axo)::VARCHAR AS concepto,
        ROUND((t.tasaporcen * 100)::NUMERIC, 4) AS porcentaje,
        t.axo::INTEGER AS anio
    FROM public.c_tasas t
    WHERE
        -- Si hay filtro, buscar en concepto generado o en año
        (v_filtro = '' OR
         CAST(t.axo AS TEXT) ILIKE '%' || v_filtro || '%' OR
         t.constbald ILIKE '%' || v_filtro || '%' OR
         CAST(t.tasa AS TEXT) = v_filtro)
    ORDER BY t.axo DESC, t.tasa
    LIMIT 100;

END;
$$;

-- Recrear la función en schema public para compatibilidad
CREATE OR REPLACE FUNCTION public.ipor_sp_list(
    p_params JSONB DEFAULT '{}'::JSONB
)
RETURNS TABLE (
    id INTEGER,
    concepto VARCHAR,
    porcentaje NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Extraer filtro del JSONB
    v_filtro := COALESCE(p_params->>'filtro', '');

    -- Buscar en la tabla c_tasas aplicando el filtro
    RETURN QUERY
    SELECT
        t.tasa::INTEGER AS id,
        ('Tasa ' || t.constbald || ' - Año ' || t.axo)::VARCHAR AS concepto,
        ROUND((t.tasaporcen * 100)::NUMERIC, 4) AS porcentaje
    FROM public.c_tasas t
    WHERE
        -- Si hay filtro, buscar en concepto generado o en año
        (v_filtro = '' OR
         CAST(t.axo AS TEXT) ILIKE '%' || v_filtro || '%' OR
         t.constbald ILIKE '%' || v_filtro || '%' OR
         CAST(t.tasa AS TEXT) = v_filtro)
    ORDER BY t.axo DESC, t.tasa
    LIMIT 100;

END;
$$;

-- Comentarios sobre el mapeo:
-- public.c_tasas.tasa -> id
-- 'Tasa ' || constbald || ' - Año ' || axo -> concepto (generado)
-- (tasaporcen * 100) -> porcentaje (convertido a porcentaje)
-- public.c_tasas.axo -> anio (año de la tasa)
-- public.c_tasas.constbald -> tipo de construcción/baldío (B, C, etc.)

-- Campos retornados:
-- id: ID de la tasa
-- concepto: Descripción generada (ej: "Tasa B - Año 2024")
-- porcentaje: Porcentaje de la tasa (multiplicado por 100)
-- anio: Año de vigencia de la tasa

-- Filtro de búsqueda:
-- Busca por año (ej: "2024", "2023")
-- Busca por tipo de construcción (ej: "B", "C")
-- Busca por ID exacto de tasa
-- Sin filtro: retorna todas las tasas (máximo 100)
