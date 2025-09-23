-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_ADEUDCOND (EXACTO del archivo original)
-- Archivo: 91_SP_ASEO_REP_ADEUDCOND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: get_tipo_aseo_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de tipos de public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_tipo_aseo_catalog()
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    cta_aplicacion integer
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
-- Formulario: REP_ADEUDCOND (EXACTO del archivo original)
-- Archivo: 91_SP_ASEO_REP_ADEUDCOND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: get_adeudos_condonados_by_contrato
-- Tipo: Report
-- Descripción: Devuelve los adeudos condonados (status 'S') para un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_adeudos_condonados_by_contrato(
    p_control_contrato integer
)
RETURNS SETOF ta_16_pagos AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM public.ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND status_vigencia = 'S';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_ADEUDCOND (EXACTO del archivo original)
-- Archivo: 91_SP_ASEO_REP_ADEUDCOND_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

