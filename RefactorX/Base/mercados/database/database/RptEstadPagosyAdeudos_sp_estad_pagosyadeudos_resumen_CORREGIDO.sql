-- ============================================
-- STORED PROCEDURE CORREGIDO
-- Formulario: RptEstadPagosyAdeudos
-- SP: sp_estad_pagosyadeudos_resumen
-- Base: mercados.public
-- Fecha: 2025-12-02
-- ============================================

DROP FUNCTION IF EXISTS sp_estad_pagosyadeudos_resumen(integer, integer, integer, date, date);

CREATE OR REPLACE FUNCTION sp_estad_pagosyadeudos_resumen(
    p_id_rec integer,
    p_axo integer,
    p_mes integer,
    p_fec3 date,
    p_fec4 date
)
RETURNS TABLE (
    tipo text,
    locales bigint,
    importe numeric,
    periodos bigint
) AS $$
BEGIN
    RETURN QUERY
    -- Pagos
    SELECT 'Pagados'::text AS tipo,
        COUNT(DISTINCT a.id_local) AS locales,
        COALESCE(SUM(c.importe_pago),0) AS importe,
        COUNT(c.id_pago_local) AS periodos
    FROM comun.ta_11_locales a
    JOIN comun.ta_11_pagos_local c ON c.id_local = a.id_local
    WHERE a.oficina = p_id_rec
      AND a.vigencia = 'A'
      AND c.fecha_pago BETWEEN p_fec3 AND p_fec4

    UNION ALL
    -- Captura
    SELECT 'Capturados'::text AS tipo,
        COUNT(DISTINCT g.id_local) AS locales,
        COALESCE(SUM(h.importe_pago),0) AS importe,
        COUNT(h.id_pago_local) AS periodos
    FROM comun.ta_11_locales g
    JOIN comun.ta_11_pagos_local h ON h.id_local = g.id_local
    WHERE g.oficina = p_id_rec
      AND g.vigencia = 'A'
      AND h.fecha_modificacion::date BETWEEN p_fec3 AND p_fec4

    UNION ALL
    -- Adeudos
    SELECT 'Adeudos'::text AS tipo,
        COUNT(DISTINCT d.id_local) AS locales,
        COALESCE(SUM(e.importe),0) AS importe,
        COUNT(e.id_adeudo_local) AS periodos
    FROM comun.ta_11_locales d
    JOIN comun.ta_11_adeudo_local e ON e.id_local = d.id_local
    WHERE d.oficina = p_id_rec
      AND d.vigencia = 'A'
      AND ((e.axo = p_axo AND e.periodo <= p_mes) OR (e.axo < p_axo));
END;
$$ LANGUAGE plpgsql;
