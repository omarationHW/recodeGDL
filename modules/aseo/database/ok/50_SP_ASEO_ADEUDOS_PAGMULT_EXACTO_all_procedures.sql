-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_PAGMULT (EXACTO del archivo original)
-- Archivo: 50_SP_ASEO_ADEUDOS_PAGMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_adeudos_pagmult_listar_catalogos
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de tipos de aseo, recaudadoras y cajas para el formulario de pagos múltiples.
-- --------------------------------------------

-- No es necesario un SP, pero si se requiere:
CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_listar_catalogos()
RETURNS TABLE(
    ctrol_aseo integer, tipo_aseo varchar, descripcion varchar,
    id_rec integer, recaudadora varchar,
    caja varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT t.ctrol_aseo, t.tipo_aseo, t.descripcion, NULL::integer, NULL::varchar, NULL::varchar FROM public.ta_16_tipo_aseo t
    UNION ALL
    SELECT NULL, NULL, NULL, r.id_rec, r.recaudadora, NULL FROM public.ta_12_recaudadoras r
    UNION ALL
    SELECT NULL, NULL, NULL, NULL, NULL, o.caja FROM public.ta_12_operaciones o;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_PAGMULT (EXACTO del archivo original)
-- Archivo: 50_SP_ASEO_ADEUDOS_PAGMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_adeudos_pagmult_listar_adeudos
-- Tipo: CRUD
-- Descripción: Lista los adeudos vigentes de un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_adeudos_pagmult_listar_adeudos(p_control_contrato integer)
RETURNS TABLE(
    control_contrato integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar,
    descripcion varchar,
    exedencias smallint,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.cve_operacion, b.descripcion, a.exedencias, a.importe
    FROM public.ta_16_pagos a
    JOIN public.ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V'
    ORDER BY a.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_PAGMULT (EXACTO del archivo original)
-- Archivo: 50_SP_ASEO_ADEUDOS_PAGMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

