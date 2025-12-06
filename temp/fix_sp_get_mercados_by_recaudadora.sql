-- ============================================
-- FIX: Eliminar versiones duplicadas de sp_get_mercados_by_recaudadora
-- Problema: PostgreSQL encuentra múltiples versiones con diferentes tipos
-- Solución: Eliminar TODAS las versiones y crear solo una correcta
-- Fecha: 2025-12-04
-- ============================================

-- Eliminar todas las posibles versiones del SP con diferentes tipos de parámetros
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(integer);
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(smallint);
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(bigint);
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(numeric);
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(integer);
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(smallint);
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(bigint);
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(numeric);

-- Crear UNA sola versión correcta del SP
-- Usar SMALLINT para coincidir con los tipos de las columnas reales
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(
    p_recaudadora_id SMALLINT
)
RETURNS TABLE(
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.num_mercado_nvo,
        m.descripcion
    FROM padron_licencias.comun.ta_11_mercados m
    WHERE m.oficina = p_recaudadora_id
      AND m.cuenta_energia > 0
    ORDER BY m.num_mercado_nvo;
END;
$$;

-- Comentario descriptivo
COMMENT ON FUNCTION sp_get_mercados_by_recaudadora(SMALLINT) IS
'Devuelve los mercados de una recaudadora que tienen energía eléctrica registrada';
