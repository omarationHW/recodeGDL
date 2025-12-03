-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptEstadPagosyAdeudos
-- SP: sp_estad_pagosyadeudos
-- Base: mercados.public
-- Fecha: 2025-12-02
-- ============================================

DROP FUNCTION IF EXISTS sp_estad_pagosyadeudos(integer, integer, integer, date, date);

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
    periodospag bigint,
    localcap integer,
    pagoscap numeric,
    periodoscap bigint,
    localade integer,
    pagosade numeric,
    periodosade bigint
) AS $$
BEGIN
    RETURN QUERY
    -- Pagos
    SELECT a.num_mercado, b.descripcion,
        COUNT(DISTINCT a.id_local)::integer AS localpag,
        COALESCE(SUM(c.importe_pago),0) AS pagospag,
        COUNT(c.id_pago_local) AS periodospag,
        0 AS localcap, 0::numeric AS pagoscap, 0::bigint AS periodoscap,
        0 AS localade, 0::numeric AS pagosade, 0::bigint AS periodosade
    FROM padron_licencias.comun.ta_11_locales a
    JOIN padron_licencias.comun.ta_11_pagos_local c ON c.id_local = a.id_local
    JOIN padron_licencias.comun.ta_11_mercados b ON b.oficina = a.oficina AND b.num_mercado_nvo = a.num_mercado
    WHERE a.oficina = p_id_rec
      AND a.vigencia = 'A'
      AND b.tipo_emision <> 'B'
      AND c.fecha_pago BETWEEN p_fec3 AND p_fec4
    GROUP BY a.num_mercado, b.descripcion

    UNION ALL
    -- Captura
    SELECT g.num_mercado, i.descripcion,
        0 AS localpag, 0::numeric AS pagospag, 0::bigint AS periodospag,
        COUNT(DISTINCT g.id_local)::integer AS localcap,
        COALESCE(SUM(h.importe_pago),0) AS pagoscap,
        COUNT(h.id_pago_local) AS periodoscap,
        0 AS localade, 0::numeric AS pagosade, 0::bigint AS periodosade
    FROM padron_licencias.comun.ta_11_locales g
    JOIN padron_licencias.comun.ta_11_pagos_local h ON h.id_local = g.id_local
    JOIN padron_licencias.comun.ta_11_mercados i ON i.oficina = g.oficina AND i.num_mercado_nvo = g.num_mercado
    WHERE g.oficina = p_id_rec
      AND g.vigencia = 'A'
      AND i.tipo_emision <> 'B'
      AND h.fecha_modificacion::date BETWEEN p_fec3 AND p_fec4
    GROUP BY g.num_mercado, i.descripcion

    UNION ALL
    -- Adeudos
    SELECT d.num_mercado, f.descripcion,
        0 AS localpag, 0::numeric AS pagospag, 0::bigint AS periodospag,
        0 AS localcap, 0::numeric AS pagoscap, 0::bigint AS periodoscap,
        COUNT(DISTINCT d.id_local)::integer AS localade,
        COALESCE(SUM(e.importe),0) AS pagosade,
        COUNT(e.id_adeudo_local) AS periodosade
    FROM padron_licencias.comun.ta_11_locales d
    JOIN padron_licencias.comun.ta_11_adeudo_local e ON e.id_local = d.id_local
    JOIN padron_licencias.comun.ta_11_mercados f ON f.oficina = d.oficina AND f.num_mercado_nvo = d.num_mercado
    WHERE d.oficina = p_id_rec
      AND d.vigencia = 'A'
      AND f.tipo_emision <> 'B'
      AND ((e.axo = p_axo AND e.periodo <= p_mes) OR (e.axo < p_axo))
    GROUP BY d.num_mercado, f.descripcion;
END;
$$ LANGUAGE plpgsql;
