-- =============================================
-- SP: sp_rpt_locales_giro
-- Descripción: Reporte de locales agrupados por tipo de giro comercial
-- Componente: RptLocalesGiro.vue
-- Base: mercados.public
-- Fecha: 2025-12-05
-- CORREGIDO: Campos ajustados (num_mercado, vigencia), tabla ta_11_giros no existe
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
    seccion VARCHAR,
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
        l.num_mercado::INTEGER,
        l.categoria::INTEGER,
        l.seccion::VARCHAR,
        l.local::INTEGER,
        l.letra_local::VARCHAR,
        l.bloque::VARCHAR,
        l.nombre::VARCHAR,
        l.giro::INTEGER,
        CASE
            WHEN l.giro IS NOT NULL THEN 'GIRO ' || l.giro::TEXT
            ELSE 'SIN GIRO'
        END::VARCHAR as descripcion_giro,
        COALESCE(l.superficie, 0)::NUMERIC(10,2) as superficie,
        0::NUMERIC(12,2) as renta
    FROM
        publico.ta_11_locales l
    WHERE
        l.oficina = p_oficina
        AND l.vigencia = 'A'
        AND (p_mercado IS NULL OR l.num_mercado = p_mercado)
        AND (p_giro IS NULL OR l.giro = p_giro)
    ORDER BY
        l.num_mercado, l.giro, l.local;
END;
$$ LANGUAGE plpgsql;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_rpt_locales_giro(INTEGER, INTEGER, INTEGER) IS
'Genera reporte de locales agrupados por tipo de giro comercial.
Parámetros: p_oficina (recaudadora), p_mercado (opcional), p_giro (opcional).
Retorna: información del local con giro, superficie (renta=0 porque el campo no existe).
NOTA: ta_11_giros no existe, descripcion_giro se genera como GIRO + número.';
