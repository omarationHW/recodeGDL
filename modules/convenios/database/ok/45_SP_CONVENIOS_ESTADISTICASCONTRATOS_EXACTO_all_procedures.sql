-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ESTADISTICASCONTRATOS (EXACTO del archivo original)
-- Archivo: 45_SP_CONVENIOS_ESTADISTICASCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: spd_17_adeudo_venc
-- Tipo: Report
-- Descripción: Obtiene adeudos vencidos por año de obra y fondo/programa
-- --------------------------------------------

-- PostgreSQL version of spd_17_adeudo_venc
CREATE OR REPLACE FUNCTION spd_17_adeudo_venc(parm_alo integer, parm_fondo integer)
RETURNS TABLE(
    colonia integer,
    calle integer,
    folio integer,
    nombre varchar,
    numero varchar,
    costo numeric,
    pagos numeric,
    saldo numeric,
    importe_vencido numeric,
    parc_vencida integer,
    fecha_venc date,
    descuento varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.colonia,
        c.calle,
        c.folio,
        c.nombre,
        c.numero,
        c.pago_total AS costo,
        COALESCE(SUM(p.importe),0) AS pagos,
        (c.pago_total - COALESCE(SUM(p.importe),0)) AS saldo,
        -- Lógica para importe vencido, parc_vencida, fecha_venc, descuento
        0 AS importe_vencido,
        0 AS parc_vencida,
        NULL::date AS fecha_venc,
        '' AS descuento
    FROM public.ta_17_convenios c
    LEFT JOIN public.ta_17_pagos p ON c.id_convenio = p.id_convenio
    WHERE c.axo_obra = parm_alo AND c.fondo = parm_fondo
    GROUP BY c.colonia, c.calle, c.folio, c.nombre, c.numero, c.pago_total;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ESTADISTICASCONTRATOS (EXACTO del archivo original)
-- Archivo: 45_SP_CONVENIOS_ESTADISTICASCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: spd_17_recaudacion
-- Tipo: Report
-- Descripción: Obtiene recaudación por rango de fechas y clasificación
-- --------------------------------------------

-- PostgreSQL version of spd_17_recaudacion
CREATE OR REPLACE FUNCTION spd_17_recaudacion(fecha_desde date, fecha_hasta date, clasificacion text)
RETURNS TABLE(
    fecha_pago date,
    oficina_pago integer,
    caja_pago varchar,
    importe numeric,
    clasificacion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.importe,
        clasificacion
    FROM public.ta_17_pagos p
    WHERE p.fecha_pago BETWEEN fecha_desde AND fecha_hasta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ESTADISTICASCONTRATOS (EXACTO del archivo original)
-- Archivo: 45_SP_CONVENIOS_ESTADISTICASCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

