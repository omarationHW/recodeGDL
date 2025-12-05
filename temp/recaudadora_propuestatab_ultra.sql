-- Stored Procedure ULTRA OPTIMIZADO: recaudadora_propuestatab
-- Con índices y búsqueda en fechas recientes

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
    v_fecha_limite DATE;
BEGIN
    -- Fecha límite: 2 años atrás desde hoy
    v_fecha_limite := CURRENT_DATE - INTERVAL '2 years';
    
    -- Limpiar espacios del filtro
    v_filtro_clean := TRIM(p_filtro);
    
    -- Intentar convertir el filtro a número
    BEGIN
        v_filtro_num := CAST(v_filtro_clean AS INTEGER);
    EXCEPTION WHEN OTHERS THEN
        v_filtro_num := NULL;
    END;

    -- BÚSQUEDA NUMÉRICA (usa índices)
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
            (p.cvecuenta = v_filtro_num
            OR p.folio = v_filtro_num
            OR p.cvepago = v_filtro_num
            OR p.recaud = v_filtro_num)
            AND p.fecha >= v_fecha_limite
        ORDER BY p.fecha DESC, p.hora DESC
        LIMIT 50;
        
    -- BÚSQUEDA POR TEXTO (usa índice de cajero)
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
            p.fecha >= v_fecha_limite
            AND (
                UPPER(TRIM(p.caja)) LIKE '%' || UPPER(v_filtro_clean) || '%'
                OR UPPER(TRIM(p.cajero)) LIKE '%' || UPPER(v_filtro_clean) || '%'
            )
        ORDER BY p.fecha DESC, p.hora DESC
        LIMIT 50;
        
    -- SIN FILTRO: Solo registros recientes (usa índice de fecha)
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
        WHERE 
            p.fecha >= v_fecha_limite
            AND p.fecha IS NOT NULL
        ORDER BY p.fecha DESC, p.hora DESC
        LIMIT 50;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_propuestatab(VARCHAR) IS 'Consulta propuestas y pagos realizados (ULTRA OPTIMIZADO con índices)';
