-- ================================================================
-- SP: recaudadora_pres
-- Módulo: multas_reglamentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-04
-- Descripción: Consulta de presupuesto devengado de ingresos
-- ================================================================

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_pres(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    ejercicio SMALLINT,
    titulo SMALLINT,
    capitulo SMALLINT,
    cta_aplicacion INTEGER,
    fecha_ingreso DATE,
    presup_anual NUMERIC,
    ingreso_total NUMERIC,
    enero NUMERIC,
    febrero NUMERIC,
    marzo NUMERIC,
    abril NUMERIC,
    mayo NUMERIC,
    junio NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ejercicio SMALLINT;
    v_cuenta INTEGER;
BEGIN
    -- Intentar convertir el filtro a número
    IF p_filtro IS NOT NULL AND TRIM(p_filtro) <> '' THEN
        BEGIN
            -- Intentar como ejercicio (año)
            IF LENGTH(TRIM(p_filtro)) = 4 THEN
                v_ejercicio := p_filtro::SMALLINT;
            ELSE
                -- Intentar como cuenta
                v_cuenta := p_filtro::INTEGER;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            v_ejercicio := NULL;
            v_cuenta := NULL;
        END;
    END IF;

    -- Retornar registros de presupuesto devengado
    RETURN QUERY
    SELECT
        p.ejercicio,
        p.titulo,
        p.capitulo,
        p.cta_aplicacion,
        p.fecha_ingreso_mod AS fecha_ingreso,
        p.presup_anual,
        (COALESCE(p.ingreso_01, 0) + COALESCE(p.ingreso_02, 0) +
         COALESCE(p.ingreso_03, 0) + COALESCE(p.ingreso_04, 0) +
         COALESCE(p.ingreso_05, 0) + COALESCE(p.ingreso_06, 0) +
         COALESCE(p.ingreso_07, 0) + COALESCE(p.ingreso_08, 0) +
         COALESCE(p.ingreso_09, 0) + COALESCE(p.ingreso_10, 0) +
         COALESCE(p.ingreso_11, 0) + COALESCE(p.ingreso_12, 0))::NUMERIC AS ingreso_total,
        p.ingreso_01 AS enero,
        p.ingreso_02 AS febrero,
        p.ingreso_03 AS marzo,
        p.ingreso_04 AS abril,
        p.ingreso_05 AS mayo,
        p.ingreso_06 AS junio
    FROM comun.ta_pres_dev_ing p
    WHERE
        (v_ejercicio IS NULL OR p.ejercicio = v_ejercicio)
        AND (v_cuenta IS NULL OR p.cta_aplicacion = v_cuenta)
    ORDER BY p.ejercicio DESC, p.titulo, p.capitulo
    LIMIT 100; -- Límite de seguridad

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_pres(VARCHAR) IS
'Consulta de presupuesto devengado de ingresos. Filtra por ejercicio (año de 4 dígitos) o cuenta de aplicación. Muestra presupuesto anual e ingresos mensuales.';
