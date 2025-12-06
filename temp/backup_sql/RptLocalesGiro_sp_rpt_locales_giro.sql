-- =============================================
-- SP: sp_rpt_locales_giro
-- Descripción: Reporte de locales agrupados por tipo de giro comercial
-- Componente: RptLocalesGiro.vue
-- Fecha: 2025-12-05
-- =============================================

DROP FUNCTION IF EXISTS public.sp_rpt_locales_giro(INTEGER, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_rpt_locales_giro(
    p_oficina INTEGER,
    p_mercado INTEGER DEFAULT NULL,
    p_giro INTEGER DEFAULT NULL
)
RETURNS TABLE(
    num_mercado INTEGER,
    categoria INTEGER,
    seccion INTEGER,
    local INTEGER,
    letra_local VARCHAR,
    bloque VARCHAR,
    nombre VARCHAR,
    giro INTEGER,
    descripcion_giro VARCHAR,
    superficie NUMERIC(10,2),
    renta NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.mercado::INTEGER as num_mercado,
        l.categoria::INTEGER,
        l.seccion::INTEGER,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        l.giro::INTEGER,
        g.descripcion::VARCHAR as descripcion_giro,
        COALESCE(l.superficie, 0)::NUMERIC(10,2) as superficie,
        COALESCE(l.renta, 0)::NUMERIC(12,2) as renta
    FROM
        padron_licencias.comun.ta_11_locales l
    LEFT JOIN
        mercados.public.ta_11_giros g ON g.id_giro = l.giro
    WHERE
        l.oficina = p_oficina
        AND l.estado = 'A'
        AND (p_mercado IS NULL OR l.mercado = p_mercado)
        AND (p_giro IS NULL OR l.giro = p_giro)
    ORDER BY
        l.mercado, l.giro, l.local;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_rpt_locales_giro(INTEGER, INTEGER, INTEGER) IS
'Genera reporte de locales agrupados por tipo de giro comercial.
Parámetros: p_oficina (recaudadora), p_mercado (opcional), p_giro (opcional).
Retorna: información del local con giro, superficie y renta.';
