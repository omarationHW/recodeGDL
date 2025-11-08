-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: PAGOS_CONS_CONT (EXACTO del archivo original)
-- Archivo: 89_SP_ASEO_PAGOS_CONS_CONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_pagos_cons_cont_buscar_pagos
-- Tipo: Report
-- Descripción: Devuelve los pagos de un contrato específico con status 'P' (pagado).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_cons_cont_buscar_pagos(p_control_contrato INTEGER)
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
           a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, c.recaudadora, a.caja, a.consec_operacion, a.folio_rcbo
    FROM public.ta_16_pagos a
    JOIN public.ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN public.ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE a.control_contrato = p_control_contrato
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: PAGOS_CONS_CONT (EXACTO del archivo original)
-- Archivo: 89_SP_ASEO_PAGOS_CONS_CONT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

