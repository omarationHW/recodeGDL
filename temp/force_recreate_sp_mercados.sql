-- Forzar recreación completa del SP eliminando cache y dependencias
-- Fecha: 2025-12-04

-- Eliminar con CASCADE para limpiar todas las dependencias
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(integer) CASCADE;
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(smallint) CASCADE;
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(bigint) CASCADE;
DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(numeric) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(integer) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(smallint) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(bigint) CASCADE;
DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(numeric) CASCADE;

-- Limpiar cache de planes de ejecución
DISCARD PLANS;

-- Crear la versión correcta
CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(
    p_recaudadora_id SMALLINT
)
RETURNS TABLE(
    num_mercado_nvo SMALLINT,
    descripcion VARCHAR(30)
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.num_mercado_nvo,
        m.descripcion::varchar(30)
    FROM padron_licencias.comun.ta_11_mercados m
    WHERE m.oficina = p_recaudadora_id
      AND m.cuenta_energia > 0
    ORDER BY m.num_mercado_nvo;
END;
$$;

-- Agregar comentario
COMMENT ON FUNCTION sp_get_mercados_by_recaudadora(SMALLINT) IS
'Devuelve los mercados de una recaudadora que tienen energía eléctrica. Retorna SMALLINT para coincidir con tipo de columna.';

-- Verificar la creación
SELECT
    p.proname,
    pg_catalog.pg_get_function_arguments(p.oid) AS arguments,
    pg_catalog.pg_get_function_result(p.oid) AS return_type
FROM pg_catalog.pg_proc p
WHERE p.proname = 'sp_get_mercados_by_recaudadora';
