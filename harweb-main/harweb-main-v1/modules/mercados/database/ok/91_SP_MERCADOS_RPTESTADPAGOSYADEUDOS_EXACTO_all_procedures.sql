-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEstadPagosyAdeudos
-- Generado: 2025-08-27 01:03:17
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_estad_pagosyadeudos
-- Tipo: Report
-- Descripción: Obtiene la estadística de pagos, capturas y adeudos de mercados para una recaudadora y periodo dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_pagosyadeudos(
    p_id_rec integer,
    p_axo integer,
    p_mes integer,
    p_fec3 date,
    p_fec4 date
)
RETURNS TABLE (
    num_mercado integer,
    descripcion text,
    localpag integer,
    pagospag numeric,
    periodospag integer,
    localcap integer,
    pagoscap numeric,
    periodoscap integer,
    localade integer,
    pagosade numeric,
    periodosade integer
) AS $$
BEGIN
    RETURN QUERY
    -- Pagos
    SELECT a.num_mercado, b.descripcion,
        COUNT(DISTINCT a.id_local) AS localpag,
        COALESCE(SUM(c.importe_pago),0) AS pagospag,
        COUNT(c.id_pago_local) AS periodospag,
        0 AS localcap, 0 AS pagoscap, 0 AS periodoscap,
        0 AS localade, 0 AS pagosade, 0 AS periodosade
    FROM public.ta_11_locales a
    JOIN public.ta_11_pagos_local c ON c.id_local = a.id_local
    JOIN public.ta_11_mercados b ON b.oficina = a.oficina AND b.num_mercado_nvo = a.num_mercado
    WHERE a.oficina = p_id_rec
      AND a.vigencia = 'A'
      AND b.tipo_emision <> 'B'
      AND c.fecha_pago BETWEEN p_fec3 AND p_fec4
    GROUP BY a.num_mercado, b.descripcion

    UNION ALL
    -- Captura
    SELECT g.num_mercado, i.descripcion,
        0 AS localpag, 0 AS pagospag, 0 AS periodospag,
        COUNT(DISTINCT g.id_local) AS localcap,
        COALESCE(SUM(h.importe_pago),0) AS pagoscap,
        COUNT(h.id_pago_local) AS periodoscap,
        0 AS localade, 0 AS pagosade, 0 AS periodosade
    FROM public.ta_11_locales g
    JOIN public.ta_11_pagos_local h ON h.id_local = g.id_local
    JOIN public.ta_11_mercados i ON i.oficina = g.oficina AND i.num_mercado_nvo = g.num_mercado
    WHERE g.oficina = p_id_rec
      AND g.vigencia = 'A'
      AND i.tipo_emision <> 'B'
      AND h.fecha_modificacion::date BETWEEN p_fec3 AND p_fec4
    GROUP BY g.num_mercado, i.descripcion

    UNION ALL
    -- Adeudos
    SELECT d.num_mercado, f.descripcion,
        0 AS localpag, 0 AS pagospag, 0 AS periodospag,
        0 AS localcap, 0 AS pagoscap, 0 AS periodoscap,
        COUNT(DISTINCT d.id_local) AS localade,
        COALESCE(SUM(e.importe),0) AS pagosade,
        COUNT(e.id_adeudo_local) AS periodosade
    FROM public.ta_11_locales d
    JOIN public.ta_11_adeudo_local e ON e.id_local = d.id_local
    JOIN public.ta_11_mercados f ON f.oficina = d.oficina AND f.num_mercado_nvo = d.num_mercado
    WHERE d.oficina = p_id_rec
      AND d.vigencia = 'A'
      AND f.tipo_emision <> 'B'
      AND ((e.axo = p_axo AND e.periodo <= p_mes) OR (e.axo < p_axo))
    GROUP BY d.num_mercado, f.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_estad_pagosyadeudos_resumen
-- Tipo: Report
-- Descripción: Resumen global de pagos, capturas y adeudos por recaudadora y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estad_pagosyadeudos_resumen(
    p_id_rec integer,
    p_axo integer,
    p_mes integer,
    p_fec3 date,
    p_fec4 date
)
RETURNS TABLE (
    tipo text,
    locales integer,
    importe numeric,
    periodos integer
) AS $$
BEGIN
    RETURN QUERY
    -- Pagos
    SELECT 'Pagados' AS tipo,
        COUNT(DISTINCT a.id_local) AS locales,
        COALESCE(SUM(c.importe_pago),0) AS importe,
        COUNT(c.id_pago_local) AS periodos
    FROM public.ta_11_locales a
    JOIN public.ta_11_pagos_local c ON c.id_local = a.id_local
    WHERE a.oficina = p_id_rec
      AND a.vigencia = 'A'
      AND c.fecha_pago BETWEEN p_fec3 AND p_fec4

    UNION ALL
    -- Captura
    SELECT 'Capturados' AS tipo,
        COUNT(DISTINCT g.id_local) AS locales,
        COALESCE(SUM(h.importe_pago),0) AS importe,
        COUNT(h.id_pago_local) AS periodos
    FROM public.ta_11_locales g
    JOIN public.ta_11_pagos_local h ON h.id_local = g.id_local
    WHERE g.oficina = p_id_rec
      AND g.vigencia = 'A'
      AND h.fecha_modificacion::date BETWEEN p_fec3 AND p_fec4

    UNION ALL
    -- Adeudos
    SELECT 'Adeudos' AS tipo,
        COUNT(DISTINCT d.id_local) AS locales,
        COALESCE(SUM(e.importe),0) AS importe,
        COUNT(e.id_adeudo_local) AS periodos
    FROM public.ta_11_locales d
    JOIN public.ta_11_adeudo_local e ON e.id_local = d.id_local
    WHERE d.oficina = p_id_rec
      AND d.vigencia = 'A'
      AND ((e.axo = p_axo AND e.periodo <= p_mes) OR (e.axo < p_axo));
END;
$$ LANGUAGE plpgsql;

-- ============================================

