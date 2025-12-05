-- Stored Procedure Optimizado: recaudadora_propuestatab
-- Descripción: Consulta propuestas y pagos realizados con filtro de búsqueda OPTIMIZADO
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
    v_filtro_clean VARCHAR;
BEGIN
    -- Limpiar espacios del filtro
    v_filtro_clean := TRIM(p_filtro);
    
    -- Intentar convertir el filtro a número para búsquedas numéricas
    BEGIN
        v_filtro_num := CAST(v_filtro_clean AS INTEGER);
    EXCEPTION WHEN OTHERS THEN
        v_filtro_num := NULL;
    END;

    -- Si hay un filtro numérico, buscar específicamente
    IF v_filtro_num IS NOT NULL THEN
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
            p.cvecuenta = v_filtro_num
            OR p.folio = v_filtro_num
            OR p.cvepago = v_filtro_num
            OR p.recaud = v_filtro_num
        ORDER BY p.fecha DESC, p.hora DESC
        LIMIT 50;
        
    -- Si hay un filtro de texto, buscar en campos texto
    ELSIF v_filtro_clean IS NOT NULL AND v_filtro_clean != '' THEN
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
            UPPER(TRIM(p.caja)) LIKE '%' || UPPER(v_filtro_clean) || '%'
            OR UPPER(TRIM(p.cajero)) LIKE '%' || UPPER(v_filtro_clean) || '%'
        ORDER BY p.fecha DESC, p.hora DESC
        LIMIT 50;
        
    -- Sin filtro, traer los más recientes
    ELSE
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
        WHERE p.fecha IS NOT NULL
        ORDER BY p.fecha DESC, p.hora DESC
        LIMIT 50;
    END IF;
END;
$$;

-- Comentarios
COMMENT ON FUNCTION public.recaudadora_propuestatab(VARCHAR) IS 'Consulta propuestas y pagos realizados con filtro de búsqueda optimizado';
