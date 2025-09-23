-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPAGOSCAPTURADOS (EXACTO del archivo original)
-- Archivo: 81_SP_CONVENIOS_RPTPAGOSCAPTURADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_rpt_pagos_capturados
-- Tipo: Report
-- Descripción: Obtiene el listado de pagos capturados para regularización de predios por subtipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_pagos_capturados(p_subtipo integer)
RETURNS TABLE (
    id_conv_predio integer,
    tipo smallint,
    subtipo smallint,
    manzana varchar(15),
    lote integer,
    letra varchar(1),
    desc_subtipo varchar(50),
    id_conv_pago integer,
    id_conv_resto integer,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago varchar(1),
    operacion_pago integer,
    pago_parcial smallint,
    total_parciales smallint,
    importe_pago numeric(18,2),
    importe_recargo numeric(18,2),
    cve_venc smallint,
    cve_descuento smallint,
    cve_bonificacion smallint,
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar(10),
    letracomp varchar(10),
    parcialidad varchar(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.id_conv_predio,
        a.tipo,
        a.subtipo,
        a.manzana,
        a.lote,
        a.letra,
        d.desc_subtipo,
        c.id_conv_pago,
        c.id_conv_resto,
        c.fecha_pago,
        c.oficina_pago,
        c.caja_pago,
        c.operacion_pago,
        c.pago_parcial,
        c.total_parciales,
        c.importe_pago,
        c.importe_recargo,
        c.cve_venc,
        c.cve_descuento,
        c.cve_bonificacion,
        c.id_usuario,
        c.fecha_actual,
        e.usuario,
        CASE WHEN a.letra = 'B' THEN 'BIS' WHEN a.letra = 'S' THEN 'SUB' ELSE ' ' END AS letracomp,
        c.pago_parcial::text || '-' || c.total_parciales::text AS parcialidad
    FROM public.ta_17_con_reg_pred a
    JOIN public.ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    JOIN public.ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto
    JOIN public.ta_17_subtipo_conv d ON a.subtipo = d.subtipo
    JOIN public.ta_12_passwords e ON a.id_usuario = e.id_usuario
    WHERE a.tipo = 14 AND a.subtipo = p_subtipo
    ORDER BY a.tipo, a.subtipo, a.manzana, a.lote, a.letra, c.fecha_pago, c.oficina_pago, c.caja_pago, c.operacion_pago, c.pago_parcial;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: RPTPAGOSCAPTURADOS (EXACTO del archivo original)
-- Archivo: 81_SP_CONVENIOS_RPTPAGOSCAPTURADOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

