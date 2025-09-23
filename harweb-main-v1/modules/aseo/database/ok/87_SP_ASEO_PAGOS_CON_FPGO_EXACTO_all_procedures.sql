-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: PAGOS_CON_FPGO (EXACTO del archivo original)
-- Archivo: 87_SP_ASEO_PAGOS_CON_FPGO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_pagos_con_fpgo_get_pagos_by_fecha
-- Tipo: Report
-- Descripción: Obtiene todos los pagos realizados en una fecha específica (por fecha_hora_pago, status_vigencia = 'P')
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_pagos_by_fecha(p_fecha DATE)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago VARCHAR,
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
    SELECT
        a.control_contrato,
        to_char(a.aso_mes_pago, 'YYYY-MM') as aso_mes_pago,
        a.ctrol_operacion,
        b.descripcion,
        a.exedencias,
        a.importe,
        a.status_vigencia,
        a.fecha_hora_pago,
        a.id_rec,
        c.recaudadora,
        a.caja,
        a.consec_operacion,
        a.folio_rcbo
    FROM public.ta_16_pagos a
    JOIN public.ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN public.ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE DATE(a.fecha_hora_pago) = p_fecha
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: PAGOS_CON_FPGO (EXACTO del archivo original)
-- Archivo: 87_SP_ASEO_PAGOS_CON_FPGO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_pagos_con_fpgo_get_tipo_aseo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_tipo_aseo_catalog()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion
    FROM public.ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

