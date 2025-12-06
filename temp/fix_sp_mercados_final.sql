-- Fix definitivo: SP acepta INTEGER (lo que Laravel envía) pero retorna SMALLINT (lo que la tabla tiene)
-- El cast de INTEGER a SMALLINT es automático en la comparación WHERE
-- Fecha: 2025-12-04

DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(integer) CASCADE;
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(smallint) CASCADE;
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(bigint) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(integer) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(smallint) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(bigint) CASCADE;

-- Limpiar cache
DISCARD PLANS;

-- Crear SP que ACEPTA y RETORNA INTEGER para máxima compatibilidad con Laravel
-- PostgreSQL hace el cast automáticamente desde/hacia SMALLINT en la tabla
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(
    p_recaudadora_id INTEGER  -- Acepta INTEGER para compatibilidad con Laravel
)
RETURNS TABLE(
    num_mercado_nvo INTEGER,  -- Retorna INTEGER para evitar problemas de cache
    descripcion VARCHAR(30)
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.num_mercado_nvo::INTEGER,  -- Cast explícito a INTEGER
        m.descripcion::varchar(30)
    FROM padron_licencias.comun.ta_11_mercados m
    WHERE m.oficina = p_recaudadora_id
      AND m.cuenta_energia > 0
    ORDER BY m.num_mercado_nvo;
END;
$$;

COMMENT ON FUNCTION sp_get_mercados_by_recaudadora(INTEGER) IS
'Devuelve mercados por recaudadora. Acepta INTEGER (Laravel) y retorna SMALLINT (tabla).';
