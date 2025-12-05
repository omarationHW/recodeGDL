-- Stored Procedure: recaudadora_proyecfrm
-- Descripción: Consulta proyectos y presupuestos
-- Parámetros:
--   p_filtro: Filtro de búsqueda (ejercicio, proyecto, o descripción)

DROP FUNCTION IF EXISTS public.recaudadora_proyecfrm(VARCHAR);

CREATE OR REPLACE FUNCTION public.recaudadora_proyecfrm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE(
    ejercicio SMALLINT,
    proyecto SMALLINT,
    descripcion TEXT,
    dependencia INTEGER,
    partida SMALLINT,
    programa SMALLINT,
    fecha_alta DATE,
    presactual NUMERIC,
    pres_oper NUMERIC,
    pres_inver NUMERIC,
    pres_otros NUMERIC,
    total_anual NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro_num INTEGER;
    v_filtro_clean VARCHAR;
BEGIN
    -- Limpiar espacios del filtro
    v_filtro_clean := TRIM(p_filtro);
    
    -- Intentar convertir el filtro a número
    BEGIN
        v_filtro_num := CAST(v_filtro_clean AS INTEGER);
    EXCEPTION WHEN OTHERS THEN
        v_filtro_num := NULL;
    END;

    -- BÚSQUEDA CON FILTRO NUMÉRICO (ejercicio o proyecto)
    IF v_filtro_num IS NOT NULL THEN
        RETURN QUERY
        SELECT
            p.ejercicio,
            p.proyecto,
            TRIM(p.descripcion),
            pp.dependencia,
            pp.partida,
            pp.programa,
            pp.fecha_alta,
            pp.presactual,
            pp.pres_oper,
            pp.pres_inver,
            pp.pres_otros,
            (pp.presup_01 + pp.presup_02 + pp.presup_03 + pp.presup_04 + 
             pp.presup_05 + pp.presup_06 + pp.presup_07 + pp.presup_08 +
             pp.presup_09 + pp.presup_10 + pp.presup_11 + pp.presup_12) as total_anual
        FROM comun.ta_proyectos p
        LEFT JOIN comun.ta_proyecto_pres pp 
            ON p.ejercicio = pp.ejercicio 
            AND p.proyecto = pp.proyecto
        WHERE 
            p.ejercicio = v_filtro_num
            OR p.proyecto = v_filtro_num
        ORDER BY p.ejercicio DESC, p.proyecto ASC
        LIMIT 50;
        
    -- BÚSQUEDA POR TEXTO (descripción)
    ELSIF v_filtro_clean IS NOT NULL AND v_filtro_clean != '' THEN
        RETURN QUERY
        SELECT
            p.ejercicio,
            p.proyecto,
            TRIM(p.descripcion),
            pp.dependencia,
            pp.partida,
            pp.programa,
            pp.fecha_alta,
            pp.presactual,
            pp.pres_oper,
            pp.pres_inver,
            pp.pres_otros,
            (pp.presup_01 + pp.presup_02 + pp.presup_03 + pp.presup_04 + 
             pp.presup_05 + pp.presup_06 + pp.presup_07 + pp.presup_08 +
             pp.presup_09 + pp.presup_10 + pp.presup_11 + pp.presup_12) as total_anual
        FROM comun.ta_proyectos p
        LEFT JOIN comun.ta_proyecto_pres pp 
            ON p.ejercicio = pp.ejercicio 
            AND p.proyecto = pp.proyecto
        WHERE 
            UPPER(TRIM(p.descripcion)) LIKE '%' || UPPER(v_filtro_clean) || '%'
        ORDER BY p.ejercicio DESC, p.proyecto ASC
        LIMIT 50;
        
    -- SIN FILTRO: Proyectos más recientes
    ELSE
        RETURN QUERY
        SELECT
            p.ejercicio,
            p.proyecto,
            TRIM(p.descripcion),
            pp.dependencia,
            pp.partida,
            pp.programa,
            pp.fecha_alta,
            pp.presactual,
            pp.pres_oper,
            pp.pres_inver,
            pp.pres_otros,
            (pp.presup_01 + pp.presup_02 + pp.presup_03 + pp.presup_04 + 
             pp.presup_05 + pp.presup_06 + pp.presup_07 + pp.presup_08 +
             pp.presup_09 + pp.presup_10 + pp.presup_11 + pp.presup_12) as total_anual
        FROM comun.ta_proyectos p
        LEFT JOIN comun.ta_proyecto_pres pp 
            ON p.ejercicio = pp.ejercicio 
            AND p.proyecto = pp.proyecto
        ORDER BY p.ejercicio DESC, p.proyecto ASC
        LIMIT 50;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_proyecfrm(VARCHAR) IS 'Consulta proyectos y presupuestos con filtro';
