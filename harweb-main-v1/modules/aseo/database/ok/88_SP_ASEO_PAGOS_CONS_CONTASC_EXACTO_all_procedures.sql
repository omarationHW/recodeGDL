-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: PAGOS_CONS_CONTASC (EXACTO del archivo original)
-- Archivo: 88_SP_ASEO_PAGOS_CONS_CONTASC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Devuelve todos los tipos de aseo activos para el combo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    cta_aplicacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM public.ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: PAGOS_CONS_CONTASC (EXACTO del archivo original)
-- Archivo: 88_SP_ASEO_PAGOS_CONS_CONTASC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_pagos_por_contrato_asc
-- Tipo: Report
-- Descripción: Devuelve los pagos del contrato (vigencia = 'P') ordenados por periodo y operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_por_contrato_asc(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago DATE,
    ctrol_operacion INTEGER,
    descripcion VARCHAR,
    exedencias SMALLINT,
    importe NUMERIC,
    status_vigencia VARCHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion,
           a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, c.recaudadora,
           a.caja, a.consec_operacion, a.folio_rcbo
    FROM public.ta_16_pagos a
    JOIN public.ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN public.ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE a.control_contrato = p_control_contrato
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

