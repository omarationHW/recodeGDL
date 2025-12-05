-- ================================================================
-- SP: recaudadora_codificafrm
-- Módulo: multas_reglamentos
-- Descripción: Codifica texto usando diferentes métodos (base64, hex, md5)
-- ================================================================

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_codificafrm(TEXT);
DROP FUNCTION IF EXISTS comun.recaudadora_codificafrm(TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_codificafrm(
    p_texto TEXT
)
RETURNS TABLE(
    texto_original TEXT,
    base64_encode TEXT,
    hex_encode TEXT,
    md5_hash TEXT,
    upper_text TEXT,
    lower_text TEXT,
    length_chars INTEGER,
    reverse_text TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validar que se envió texto
    IF p_texto IS NULL OR TRIM(p_texto) = '' THEN
        RETURN QUERY
        SELECT
            'Sin texto'::TEXT,
            ''::TEXT,
            ''::TEXT,
            ''::TEXT,
            ''::TEXT,
            ''::TEXT,
            0::INTEGER,
            ''::TEXT;
        RETURN;
    END IF;

    -- Retornar texto codificado en diferentes formatos
    RETURN QUERY
    SELECT
        p_texto::TEXT AS texto_original,
        encode(p_texto::bytea, 'base64')::TEXT AS base64_encode,
        encode(p_texto::bytea, 'hex')::TEXT AS hex_encode,
        md5(p_texto)::TEXT AS md5_hash,
        UPPER(p_texto)::TEXT AS upper_text,
        LOWER(p_texto)::TEXT AS lower_text,
        LENGTH(p_texto)::INTEGER AS length_chars,
        REVERSE(p_texto)::TEXT AS reverse_text;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            p_texto::TEXT,
            ('Error: ' || SQLERRM)::TEXT,
            ''::TEXT,
            ''::TEXT,
            ''::TEXT,
            ''::TEXT,
            0::INTEGER,
            ''::TEXT;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_codificafrm(TEXT)
IS 'Codifica texto usando diferentes métodos: Base64, Hexadecimal, MD5, Mayúsculas, Minúsculas y más.';
