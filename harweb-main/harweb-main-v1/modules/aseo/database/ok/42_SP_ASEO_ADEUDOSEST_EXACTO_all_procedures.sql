-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOSEST (EXACTO del archivo original)
-- Archivo: 42_SP_ASEO_ADEUDOSEST_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_estadistico_pagos
-- Tipo: Report
-- Descripción: Devuelve el estadístico de pagos por periodo, sumando importe de cuota normal, excedente y contenedores, para cada periodo entre dos fechas dadas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_estadistico_pagos(p_periodo_inicio TEXT, p_periodo_fin TEXT)
RETURNS TABLE (
    periodo TEXT,
    cuota_normal NUMERIC,
    excedente NUMERIC,
    contenedores NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        to_char(aso_mes_recargo, 'YYYY-MM') AS periodo,
        COALESCE((SELECT SUM(importe) FROM public.ta_16_pagos WHERE to_char(aso_mes_pago, 'YYYY-MM') = to_char(r.aso_mes_recargo, 'YYYY-MM') AND ctrol_operacion = 6 AND status_vigencia = 'P'), 0) AS cuota_normal,
        COALESCE((SELECT SUM(importe) FROM public.ta_16_pagos WHERE to_char(aso_mes_pago, 'YYYY-MM') = to_char(r.aso_mes_recargo, 'YYYY-MM') AND ctrol_operacion = 7 AND status_vigencia = 'P'), 0) AS excedente,
        COALESCE((SELECT SUM(importe) FROM public.ta_16_pagos WHERE to_char(aso_mes_pago, 'YYYY-MM') = to_char(r.aso_mes_recargo, 'YYYY-MM') AND ctrol_operacion = 8 AND status_vigencia = 'P'), 0) AS contenedores
    FROM public.ta_16_recargos r
    WHERE to_char(r.aso_mes_recargo, 'YYYY-MM') BETWEEN p_periodo_inicio AND p_periodo_fin
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

