-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptPadronGlobal
-- Generado: 2025-08-27 01:26:10
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_padron_global
-- Tipo: Report
-- Descripción: Obtiene el padrón global de locales con cálculo de renta y estatus de adeudo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padron_global(p_year integer, p_month integer, p_status varchar)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar,
    superficie numeric,
    vigencia varchar,
    clave_cuota smallint,
    descripcion varchar,
    renta numeric,
    leyenda varchar,
    adeudo integer,
    registro varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta
        CASE
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * c.importe_cuota
            WHEN l.seccion = 'PS' THEN (c.importe_cuota * l.superficie) * 30
            WHEN l.num_mercado = 214 THEN (l.superficie * c.importe_cuota) * COALESCE(fd.sabadosacum, 1)
            ELSE l.superficie * c.importe_cuota
        END AS renta,
        -- Leyenda y adeudo
        CASE WHEN a.adeudos >= 1 THEN 'Local con Adeudo' ELSE 'Local al Corriente de Pagos' END AS leyenda,
        CASE WHEN a.adeudos >= 1 THEN 1 ELSE 0 END AS adeudo,
        -- Registro
        l.oficina::text || ' ' || l.num_mercado::text || ' ' || l.categoria::text || ' ' || l.seccion || ' ' || l.local::text || ' ' || COALESCE(l.letra_local, '') || ' ' || COALESCE(l.bloque, '') AS registro
    FROM public.ta_11_locales l
    INNER JOIN public.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    INNER JOIN public.ta_11_cuo_locales c ON c.axo = p_year AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT id_local, COUNT(*) AS adeudos
        FROM public.ta_11_adeudo_local
        WHERE (axo = p_year AND periodo <= p_month) OR (axo < p_year)
        GROUP BY id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN public.ta_11_fecha_desc fd ON fd.mes = p_month
    WHERE (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY l.vigencia, l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

