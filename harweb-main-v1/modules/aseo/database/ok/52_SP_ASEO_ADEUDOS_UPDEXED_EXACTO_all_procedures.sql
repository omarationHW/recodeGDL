-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_UPDEXED (EXACTO del archivo original)
-- Archivo: 52_SP_ASEO_ADEUDOS_UPDEXED_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_adeudos_updexed_search
-- Tipo: CRUD
-- Descripción: Busca la excedencia vigente para un contrato, periodo y tipo de operación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_updexed_search(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER
) RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    ctrol_recolec INTEGER,
    costo_exed NUMERIC,
    aso_mes_oblig DATE,
    exedencias INTEGER,
    importe NUMERIC,
    aso_mes_pago VARCHAR,
    status_vigencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.num_contrato, a.ctrol_aseo, a.ctrol_recolec, c.costo_exed, a.aso_mes_oblig,
           p.exedencias, p.importe, p.aso_mes_pago, p.status_vigencia
    FROM public.ta_16_contratos a
    JOIN public.ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN public.ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
    JOIN public.ta_16_pagos p ON p.control_contrato = a.control_contrato
        AND p.aso_mes_pago = lpad(p_ejercicio::text,4,'0')||'-'||lpad(p_mes::text,2,'0')
        AND p.ctrol_operacion = p_ctrol_operacion
        AND p.status_vigencia = 'V'
    WHERE a.num_contrato = p_num_contrato AND a.ctrol_aseo = p_ctrol_aseo
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_UPDEXED (EXACTO del archivo original)
-- Archivo: 52_SP_ASEO_ADEUDOS_UPDEXED_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_adeudos_updexed_catalogs
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipos de aseo, tipos de operación y meses.
-- --------------------------------------------

-- No es un SP, pero para uniformidad:
-- SELECT ctrol_aseo, tipo_aseo, descripcion FROM public.ta_16_tipo_aseo ORDER BY ctrol_aseo;
-- SELECT ctrol_operacion, cve_operacion, descripcion FROM public.ta_16_operacion WHERE ctrol_operacion > 6 ORDER BY ctrol_operacion;

-- ============================================

