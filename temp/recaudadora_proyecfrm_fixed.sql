-- Stored Procedure: recaudadora_proyecfrm (CORREGIDO)
-- Descripción: Consulta proyectos y presupuestos SIN DUPLICADOS
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
            MAX(pp.dependencia) as dependencia,
            MAX(pp.partida) as partida,
            MAX(pp.programa) as programa,
            MAX(pp.fecha_alta) as fecha_alta,
            SUM(pp.presactual) as presactual,
            SUM(pp.pres_oper) as pres_oper,
            SUM(pp.pres_inver) as pres_inver,
            SUM(pp.pres_otros) as pres_otros,
            SUM(COALESCE(pp.presup_01, 0) + COALESCE(pp.presup_02, 0) + COALESCE(pp.presup_03, 0) + COALESCE(pp.presup_04, 0) +
                COALESCE(pp.presup_05, 0) + COALESCE(pp.presup_06, 0) + COALESCE(pp.presup_07, 0) + COALESCE(pp.presup_08, 0) +
                COALESCE(pp.presup_09, 0) + COALESCE(pp.presup_10, 0) + COALESCE(pp.presup_11, 0) + COALESCE(pp.presup_12, 0)) as total_anual
        FROM comun.ta_proyectos p
        LEFT JOIN comun.ta_proyecto_pres pp
            ON p.ejercicio = pp.ejercicio
            AND p.proyecto = pp.proyecto
        WHERE
            p.ejercicio = v_filtro_num
            OR p.proyecto = v_filtro_num
        GROUP BY p.ejercicio, p.proyecto, p.descripcion
        ORDER BY p.ejercicio DESC, p.proyecto ASC
        LIMIT 50;

    -- BÚSQUEDA POR TEXTO (descripción)
    ELSIF v_filtro_clean IS NOT NULL AND v_filtro_clean != '' THEN
        RETURN QUERY
        SELECT
            p.ejercicio,
            p.proyecto,
            TRIM(p.descripcion),
            MAX(pp.dependencia) as dependencia,
            MAX(pp.partida) as partida,
            MAX(pp.programa) as programa,
            MAX(pp.fecha_alta) as fecha_alta,
            SUM(pp.presactual) as presactual,
            SUM(pp.pres_oper) as pres_oper,
            SUM(pp.pres_inver) as pres_inver,
            SUM(pp.pres_otros) as pres_otros,
            SUM(COALESCE(pp.presup_01, 0) + COALESCE(pp.presup_02, 0) + COALESCE(pp.presup_03, 0) + COALESCE(pp.presup_04, 0) +
                COALESCE(pp.presup_05, 0) + COALESCE(pp.presup_06, 0) + COALESCE(pp.presup_07, 0) + COALESCE(pp.presup_08, 0) +
                COALESCE(pp.presup_09, 0) + COALESCE(pp.presup_10, 0) + COALESCE(pp.presup_11, 0) + COALESCE(pp.presup_12, 0)) as total_anual
        FROM comun.ta_proyectos p
        LEFT JOIN comun.ta_proyecto_pres pp
            ON p.ejercicio = pp.ejercicio
            AND p.proyecto = pp.proyecto
        WHERE
            UPPER(TRIM(p.descripcion)) LIKE '%' || UPPER(v_filtro_clean) || '%'
        GROUP BY p.ejercicio, p.proyecto, p.descripcion
        ORDER BY p.ejercicio DESC, p.proyecto ASC
        LIMIT 50;

    -- SIN FILTRO: Proyectos más recientes
    ELSE
        RETURN QUERY
        SELECT
            p.ejercicio,
            p.proyecto,
            TRIM(p.descripcion),
            MAX(pp.dependencia) as dependencia,
            MAX(pp.partida) as partida,
            MAX(pp.programa) as programa,
            MAX(pp.fecha_alta) as fecha_alta,
            SUM(pp.presactual) as presactual,
            SUM(pp.pres_oper) as pres_oper,
            SUM(pp.pres_inver) as pres_inver,
            SUM(pp.pres_otros) as pres_otros,
            SUM(COALESCE(pp.presup_01, 0) + COALESCE(pp.presup_02, 0) + COALESCE(pp.presup_03, 0) + COALESCE(pp.presup_04, 0) +
                COALESCE(pp.presup_05, 0) + COALESCE(pp.presup_06, 0) + COALESCE(pp.presup_07, 0) + COALESCE(pp.presup_08, 0) +
                COALESCE(pp.presup_09, 0) + COALESCE(pp.presup_10, 0) + COALESCE(pp.presup_11, 0) + COALESCE(pp.presup_12, 0)) as total_anual
        FROM comun.ta_proyectos p
        LEFT JOIN comun.ta_proyecto_pres pp
            ON p.ejercicio = pp.ejercicio
            AND p.proyecto = pp.proyecto
        GROUP BY p.ejercicio, p.proyecto, p.descripcion
        ORDER BY p.ejercicio DESC, p.proyecto ASC
        LIMIT 50;
    END IF;
END;
$$;

COMMENT ON FUNCTION public.recaudadora_proyecfrm(VARCHAR) IS 'Consulta proyectos y presupuestos con filtro (sin duplicados)';
