-- =====================================================
-- SP: apremiossvn_pagos_list
-- Descripción: Lista pagos de apremios con filtros y totalizaciones
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_pagos_list(
    p_zona INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_vigencia VARCHAR(10) DEFAULT NULL,
    p_modulo INTEGER DEFAULT NULL
)
RETURNS TABLE (
    folio INTEGER,
    expediente VARCHAR(50),
    fecha_emision DATE,
    fecha_pago DATE,
    importe_global NUMERIC(12,2),
    importe_pago NUMERIC(12,2),
    saldo NUMERIC(12,2),
    porcentaje_pago NUMERIC(5,2),
    vigencia VARCHAR(10),
    modulo SMALLINT,
    zona SMALLINT,
    recaudadora SMALLINT,
    caja VARCHAR,
    operacion INTEGER,
    datos VARCHAR,
    dias_para_pago INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        (a.zona::VARCHAR || '-' || a.modulo::VARCHAR || '-' || a.folio::VARCHAR)::VARCHAR(50) AS expediente,
        a.fecha_emision,
        a.fecha_pago,
        COALESCE(a.importe_global, 0) AS importe_global,
        COALESCE(a.importe_pago, 0) AS importe_pago,
        COALESCE(a.importe_global, 0) - COALESCE(a.importe_pago, 0) AS saldo,
        CASE
            WHEN a.importe_global > 0 THEN
                ROUND((a.importe_pago / a.importe_global * 100), 2)
            ELSE 0
        END AS porcentaje_pago,
        CASE
            WHEN a.vigencia = '1' THEN 'Vigente'
            WHEN a.vigencia = '2' THEN 'Pagado'
            WHEN a.vigencia = 'P' THEN 'Pago Parcial'
            WHEN a.vigencia = '3' THEN 'Cancelado'
            ELSE 'Otro'
        END::VARCHAR(10) AS vigencia,
        a.modulo,
        a.zona,
        a.recaudadora,
        a.caja,
        a.operacion,
        a.datos,
        CASE
            WHEN a.fecha_pago IS NOT NULL AND a.fecha_emision IS NOT NULL THEN
                EXTRACT(DAY FROM a.fecha_pago - a.fecha_emision)::INTEGER
            ELSE NULL
        END AS dias_para_pago
    FROM ta_15_apremios a
    WHERE (p_zona IS NULL OR a.zona = p_zona)
      AND (p_modulo IS NULL OR a.modulo = p_modulo)
      AND (p_fecha_desde IS NULL OR a.fecha_pago >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR a.fecha_pago <= p_fecha_hasta)
      AND (p_vigencia IS NULL OR a.vigencia = p_vigencia)
      AND a.fecha_pago IS NOT NULL
    ORDER BY a.fecha_pago DESC, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_pagos_list();
-- SELECT * FROM apremiossvn_pagos_list(1, '2025-01-01', '2025-12-31', '2', NULL);
-- SELECT * FROM apremiossvn_pagos_list(NULL, '2025-01-01', CURRENT_DATE, NULL, 5);
