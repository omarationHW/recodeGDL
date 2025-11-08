-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTPAGOSXCONTRATO (EXACTO del archivo original)
-- Archivo: 112_SP_ASEO_SQRPTPAGOSXCONTRATO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_pagos_por_contrato
-- Tipo: Report
-- Descripción: Devuelve los pagos por contrato, con los campos requeridos para el reporte, filtrando por control_contrato, status_vigencia = 'P', y uniendo con operaciones y recaudadoras.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_pagos_por_contrato(
    p_control_contrato integer,
    p_contrato integer,
    p_ctrol_aseo integer
)
RETURNS TABLE (
    control_contrato integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    descripcion varchar,
    exedencias smallint,
    importe numeric(18,2),
    status_vigencia varchar(1),
    fecha_hora_pago timestamp,
    id_rec smallint,
    recaudadora varchar,
    caja varchar(1),
    consec_operacion integer,
    folio_rcbo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion,
           a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec,
           c.recaudadora, a.caja, a.consec_operacion, a.folio_rcbo
    FROM public.ta_16_pagos a
    JOIN public.ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN public.ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE a.control_contrato = p_control_contrato
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

