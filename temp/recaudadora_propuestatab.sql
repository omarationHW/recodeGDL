-- Stored Procedure: recaudadora_propuestatab
-- Descripción: Consulta propuestas y pagos realizados con filtro de búsqueda
-- Parámetros:
--   p_filtro: Filtro de búsqueda (puede ser cvecuenta, folio, recaud, etc.)

-- Eliminar función existente si existe
DROP FUNCTION IF EXISTS public.recaudadora_propuestatab(VARCHAR);

CREATE OR REPLACE FUNCTION public.recaudadora_propuestatab(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE(
    cvepago INTEGER,
    cvecuenta INTEGER,
    recaud SMALLINT,
    caja TEXT,
    folio INTEGER,
    fecha DATE,
    hora TEXT,
    importe NUMERIC,
    cajero TEXT,
    cveconcepto INTEGER,
    estado TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro_num INTEGER;
BEGIN
    -- Intentar convertir el filtro a número para búsquedas numéricas
    BEGIN
        v_filtro_num := CAST(p_filtro AS INTEGER);
    EXCEPTION WHEN OTHERS THEN
        v_filtro_num := NULL;
    END;

    RETURN QUERY
    SELECT
        p.cvepago,
        p.cvecuenta,
        p.recaud,
        TRIM(p.caja),
        p.folio,
        p.fecha,
        TO_CHAR(p.hora, 'HH24:MI:SS'),
        p.importe,
        TRIM(p.cajero),
        p.cveconcepto,
        CASE
            WHEN p.cvecanc IS NOT NULL THEN 'CANCELADO'
            ELSE 'ACTIVO'
        END
    FROM comun.pagos p
    WHERE
        (p_filtro = '' OR p_filtro IS NULL)
        OR (v_filtro_num IS NOT NULL AND (
            p.cvecuenta = v_filtro_num
            OR p.folio = v_filtro_num
            OR p.cvepago = v_filtro_num
            OR p.recaud = v_filtro_num
        ))
        OR (v_filtro_num IS NULL AND (
            TRIM(p.caja) ILIKE '%' || p_filtro || '%'
            OR TRIM(p.cajero) ILIKE '%' || p_filtro || '%'
        ))
    ORDER BY p.fecha DESC, p.hora DESC
    LIMIT 100;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION public.recaudadora_propuestatab(VARCHAR) IS 'Consulta propuestas y pagos realizados con filtro de búsqueda';
