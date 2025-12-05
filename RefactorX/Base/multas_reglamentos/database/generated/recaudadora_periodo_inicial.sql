-- ================================================================
-- SP: recaudadora_periodo_inicial
-- Módulo: multas_reglamentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-04
-- Descripción: Consulta los parámetros del período inicial del sistema
-- ================================================================

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_periodo_inicial(
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    municipio VARCHAR,
    ejercicio INTEGER,
    bimestre_inicial SMALLINT,
    año_inicial SMALLINT,
    bimestre_final SMALLINT,
    año_final SMALLINT,
    director VARCHAR,
    tesorero VARCHAR,
    presidente VARCHAR,
    salario VARCHAR,
    aplica_descuento_recargo VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si no se proporciona ejercicio, usar el año del sistema
    IF p_ejercicio IS NULL OR p_ejercicio = 0 THEN
        p_ejercicio := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    END IF;

    -- Retornar parámetros del sistema
    RETURN QUERY
    SELECT
        BTRIM(p.municipio::TEXT)::VARCHAR AS municipio,
        p_ejercicio AS ejercicio,
        p.bimini AS bimestre_inicial,
        p.axoini AS año_inicial,
        p.bimfin AS bimestre_final,
        p.axofin AS año_final,
        BTRIM(p.director::TEXT)::VARCHAR AS director,
        BTRIM(p.tesorero::TEXT)::VARCHAR AS tesorero,
        BTRIM(p.presidente::TEXT)::VARCHAR AS presidente,
        BTRIM(p.salario::TEXT)::VARCHAR AS salario,
        BTRIM(p.apldescrec::TEXT)::VARCHAR AS aplica_descuento_recargo
    FROM catastro_gdl.parametros p
    WHERE p.axoini <= p_ejercicio AND p.axofin >= p_ejercicio
    LIMIT 1;

    -- Si no hay resultados, retornar el registro actual
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            BTRIM(p.municipio::TEXT)::VARCHAR AS municipio,
            p_ejercicio AS ejercicio,
            p.bimini AS bimestre_inicial,
            p.axoini AS año_inicial,
            p.bimfin AS bimestre_final,
            p.axofin AS año_final,
            BTRIM(p.director::TEXT)::VARCHAR AS director,
            BTRIM(p.tesorero::TEXT)::VARCHAR AS tesorero,
            BTRIM(p.presidente::TEXT)::VARCHAR AS presidente,
            BTRIM(p.salario::TEXT)::VARCHAR AS salario,
            BTRIM(p.apldescrec::TEXT)::VARCHAR AS aplica_descuento_recargo
        FROM catastro_gdl.parametros p
        LIMIT 1;
    END IF;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_periodo_inicial(INTEGER) IS
'Consulta los parámetros del período inicial del sistema para un ejercicio específico. Si no se proporciona ejercicio, usa el año actual.';
