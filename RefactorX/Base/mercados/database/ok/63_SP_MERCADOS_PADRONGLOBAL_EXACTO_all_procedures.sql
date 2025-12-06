-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: mercados
-- ESQUEMA: public
-- ============================================
-- \c mercados;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: PadronGlobal
-- Generado: 2025-08-27 00:18:40
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_padron_global
-- Tipo: Report
-- Descripción: Obtiene el padrón global de locales con cálculo de renta y leyenda de adeudo/corriente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_padron_global(p_axo integer, p_mes integer, p_vig character varying)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion char(2),
    local smallint,
    letra_local varchar(3),
    bloque varchar(2),
    nombre varchar(30),
    descripcion_local char(20),
    superficie numeric,
    vigencia char(1),
    clave_cuota smallint,
    descripcion varchar(30),
    renta numeric,
    leyenda varchar(60),
    adeudo integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
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
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN l.superficie * COALESCE(c.importe_cuota, 0)
            WHEN l.seccion = 'PS' THEN (COALESCE(c.importe_cuota, 0) * l.superficie) * 30
            WHEN l.num_mercado = 214 THEN (l.superficie * COALESCE(c.importe_cuota, 0)) * COALESCE(fd.sabadosacum, 1)
            ELSE l.superficie * COALESCE(c.importe_cuota, 0)
        END AS renta,
        -- Leyenda y adeudo
        CASE
            WHEN (SELECT COUNT(1)
                  FROM public.ta_11_adeudo_local al
                  WHERE al.id_local = l.id_local
                  AND ((al.axo = p_axo AND al.periodo <= p_mes) OR (al.axo < p_axo))) >= 1
            THEN 'Local con Adeudo'::varchar(60)
            ELSE 'Local al Corriente de Pagos'::varchar(60)
        END AS leyenda,
        CASE
            WHEN (SELECT COUNT(1)
                  FROM public.ta_11_adeudo_local al
                  WHERE al.id_local = l.id_local
                  AND ((al.axo = p_axo AND al.periodo <= p_mes) OR (al.axo < p_axo))) >= 1
            THEN 1
            ELSE 0
        END AS adeudo
    FROM public.ta_11_localpaso l
    JOIN public.ta_11_mercados m ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN public.ta_11_cuo_locales c ON c.axo = p_axo AND c.categoria = l.categoria AND c.seccion = l.seccion AND c.clave_cuota = l.clave_cuota
    LEFT JOIN public.ta_11_fecha_desc fd ON fd.mes = p_mes
    WHERE l.num_mercado <> 99
      AND l.vigencia = p_vig
    ORDER BY l.oficina, l.num_mercado, l.categoria, l.seccion, l.local, l.letra_local, l.bloque;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_vencimiento_rec
-- Tipo: Catalog
-- Descripción: Obtiene los vencimientos de recargos y descuentos para un mes dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_vencimiento_rec(p_mes integer)
RETURNS TABLE (
    mes smallint,
    fecha_recargos date,
    fecha_descuento date,
    trimestre smallint,
    sabados smallint,
    sabadosacum smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, fecha_recargos, fecha_descuento, trimestre, sabados, sabadosacum
    FROM public.ta_11_fecha_desc
    WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

