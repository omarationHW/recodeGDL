-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: AdeudosEst
-- Generado: 2025-08-27 13:35:44
-- Total SPs: 1
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
        COALESCE((SELECT SUM(importe) FROM ta_16_pagos WHERE to_char(aso_mes_pago, 'YYYY-MM') = to_char(r.aso_mes_recargo, 'YYYY-MM') AND ctrol_operacion = 6 AND status_vigencia = 'P'), 0) AS cuota_normal,
        COALESCE((SELECT SUM(importe) FROM ta_16_pagos WHERE to_char(aso_mes_pago, 'YYYY-MM') = to_char(r.aso_mes_recargo, 'YYYY-MM') AND ctrol_operacion = 7 AND status_vigencia = 'P'), 0) AS excedente,
        COALESCE((SELECT SUM(importe) FROM ta_16_pagos WHERE to_char(aso_mes_pago, 'YYYY-MM') = to_char(r.aso_mes_recargo, 'YYYY-MM') AND ctrol_operacion = 8 AND status_vigencia = 'P'), 0) AS contenedores
    FROM ta_16_recargos r
    WHERE to_char(r.aso_mes_recargo, 'YYYY-MM') BETWEEN p_periodo_inicio AND p_periodo_fin
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

