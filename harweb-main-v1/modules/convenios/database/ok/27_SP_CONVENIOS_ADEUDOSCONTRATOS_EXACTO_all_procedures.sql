-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ADEUDOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 27_SP_CONVENIOS_ADEUDOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_adeudos_contratos_listado_todos
-- Tipo: Report
-- Descripción: Listado de todos los convenios vigentes por colonia y calle
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_todos(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           CASE WHEN (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio))) > 0 THEN 'ADE'
                WHEN (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio))) = 0 THEN 'LIQ'
                ELSE 'SAF' END AS concepto
    FROM public.ta_17_convenios a
    LEFT JOIN public.ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN public.ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN public.ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ADEUDOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 27_SP_CONVENIOS_ADEUDOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_adeudos_contratos_listado_saldos_favor
-- Tipo: Report
-- Descripción: Listado de contratos vigentes con saldos a favor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_saldos_favor(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'SAF' AS concepto
    FROM public.ta_17_convenios a
    LEFT JOIN public.ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN public.ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN public.ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio))) < 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ADEUDOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 27_SP_CONVENIOS_ADEUDOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_adeudos_contratos_listado_liquidados_col_calle
-- Tipo: Report
-- Descripción: Listado de contratos vigentes liquidados por colonia y calle
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_contratos_listado_liquidados_col_calle(p_colonia integer, p_calle integer)
RETURNS TABLE(
    id_convenio integer,
    colonia integer,
    calle integer,
    folio integer,
    nombre text,
    pago_total numeric,
    pagos numeric,
    desc_calle text,
    descripcion text,
    devolucion numeric,
    concepto text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total,
           COALESCE(SUM(b.importe),0) AS pagos, c.desc_calle, d.descripcion,
           (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio) AS devolucion,
           'LIQ' AS concepto
    FROM public.ta_17_convenios a
    LEFT JOIN public.ta_17_pagos b ON a.id_convenio = b.id_convenio AND b.fecha_pago >= a.fecha_firma
    JOIN public.ta_17_calles c ON a.colonia = c.colonia AND a.calle = c.calle
    JOIN public.ta_17_colonias d ON a.colonia = d.colonia
    WHERE a.colonia = p_colonia AND a.calle = p_calle AND a.vigencia = 'A'
    GROUP BY a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.pago_total, c.desc_calle, d.descripcion
    HAVING (a.pago_total - (COALESCE(SUM(b.importe),0) - (SELECT COALESCE(SUM(importe),0) FROM public.ta_17_devoluciones WHERE id_convenio=a.id_convenio))) <= 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ADEUDOSCONTRATOS (EXACTO del archivo original)
-- Archivo: 27_SP_CONVENIOS_ADEUDOSCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

