-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTADEUDOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 68_SP_CONVENIOS_RPTADEUDOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_adeudos_contratos
-- Tipo: Report
-- Descripción: Genera el listado de adeudos, saldos a favor o liquidados por colonia y calle, según el tipo de reporte.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_adeudos_contratos(
    p_colonia integer,
    p_calle integer,
    p_rep integer DEFAULT 1
)
RETURNS TABLE (
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre varchar,
    pago_total numeric,
    pagos numeric,
    desc_calle varchar,
    descripcion varchar,
    devolucion numeric,
    recargos numeric,
    recargosnvo numeric,
    pagosreal numeric,
    concepto varchar
) AS $$
BEGIN
    RETURN QUERY
    WITH pagos_cte AS (
        SELECT
            a.id_convenio,
            a.colonia,
            a.calle,
            a.folio,
            a.nombre,
            a.pago_total,
            COALESCE(SUM(b.importe),0) AS pagos,
            c.desc_calle,
            d.descripcion,
            (
                SELECT COALESCE(SUM(importe),0)
                FROM public.ta_17_devoluciones
                WHERE id_convenio = a.id_convenio
            ) AS devolucion,
            (
                SELECT COALESCE(SUM(g.importe),0)
                FROM public.ta_17_convenios h
                JOIN public.ta_17_pagos f ON f.id_convenio = h.id_convenio
                JOIN public.ta_12_recibosdet g ON g.fecha = f.fecha_pago
                    AND g.id_rec = f.oficina_pago
                    AND g.caja = f.caja_pago
                    AND g.operacion = f.operacion_pago
                WHERE h.id_convenio = a.id_convenio
                  AND h.clave_historia = 2
                  AND f.fecha_pago >= h.fecha_firma
                  AND f.fecha_pago <= h.fecha_vencimiento
                  AND g.cuenta IN (46210,570200000)
            ) AS recargos,
            0.00 AS recargosnvo
        FROM public.ta_17_convenios a
        LEFT JOIN public.ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
        JOIN public.ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
        JOIN public.ta_17_colonias d ON a.colonia = d.colonia
        WHERE a.colonia = p_colonia
          AND a.calle = p_calle
          AND a.vigencia = 'A'
        GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    )
    SELECT
        id_convenio,
        colonia,
        calle,
        folio,
        nombre,
        pago_total,
        pagos,
        desc_calle,
        descripcion,
        devolucion,
        recargos,
        recargosnvo,
        (pagos + recargos + recargosnvo - devolucion) AS pagosreal,
        CASE
            WHEN (pago_total - (pagos + recargos + recargosnvo - devolucion)) > 0 THEN 'ADE'
            WHEN (pago_total - (pagos + recargos + recargosnvo - devolucion)) = 0 THEN 'LIQ'
            ELSE 'SAF'
        END AS concepto
    FROM pagos_cte
    WHERE (
        (p_rep = 1 AND (pago_total - (pagos + recargos + recargosnvo - devolucion)) > 0)
        OR (p_rep = 2 AND (pago_total - (pagos + recargos + recargosnvo - devolucion)) < 0)
        OR (p_rep = 3 AND (pago_total - (pagos + recargos + recargosnvo - devolucion)) <= 0)
    )
    ORDER BY colonia, calle, folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

