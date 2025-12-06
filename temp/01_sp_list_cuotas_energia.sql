-- =====================================================
-- SP: sp_list_cuotas_energia
-- Descripción: Lista cuotas de energía con filtros opcionales
-- Parámetros:
--   p_axo: Año (NULL = todos)
--   p_periodo: Periodo (NULL = todos)
-- =====================================================

DROP FUNCTION IF EXISTS public.sp_list_cuotas_energia(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_list_cuotas_energia(
    p_axo INTEGER DEFAULT NULL,
    p_periodo INTEGER DEFAULT NULL
)
RETURNS TABLE (
    id_kilowhatts INTEGER,
    axo INTEGER,
    periodo INTEGER,
    importe NUMERIC(18,6),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        k.id_kilowhatts,
        k.axo::INTEGER,
        k.periodo::INTEGER,
        k.importe,
        k.fecha_alta,
        k.id_usuario,
        COALESCE(u.usuario, 'SIN USUARIO')::VARCHAR(50) as usuario
    FROM public.ta_11_kilowhatts k
    LEFT JOIN public.usuarios u ON k.id_usuario = u.id
    WHERE (p_axo IS NULL OR k.axo = p_axo)
      AND (p_periodo IS NULL OR k.periodo = p_periodo)
    ORDER BY k.axo DESC, k.periodo DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_list_cuotas_energia(INTEGER, INTEGER) IS
'Lista cuotas de energía eléctrica con filtros opcionales por año y periodo. Incluye información del usuario.';
