-- =====================================================
-- SP: apremiossvn_listados_ade
-- Descripción: Listados de adeudos (ADE) con cálculos de montos pendientes
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_listados_ade(
    p_zona INTEGER DEFAULT NULL,
    p_modulo INTEGER DEFAULT NULL,
    p_tipo_adeudo VARCHAR(50) DEFAULT 'TODOS',
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE (
    folio INTEGER,
    expediente VARCHAR(50),
    fecha_emision DATE,
    importe_original NUMERIC(12,2),
    importe_pagado NUMERIC(12,2),
    saldo_pendiente NUMERIC(12,2),
    porcentaje_adeudo NUMERIC(5,2),
    dias_vencidos INTEGER,
    modulo SMALLINT,
    zona SMALLINT,
    vigencia VARCHAR(10),
    ejecutor_nombre VARCHAR(60),
    datos VARCHAR,
    observaciones VARCHAR,
    clasificacion VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        (a.zona::VARCHAR || '-' || a.modulo::VARCHAR || '-' || a.folio::VARCHAR)::VARCHAR(50) AS expediente,
        a.fecha_emision,
        COALESCE(a.importe_global, 0) AS importe_original,
        COALESCE(a.importe_pago, 0) AS importe_pagado,
        COALESCE(a.importe_global, 0) - COALESCE(a.importe_pago, 0) AS saldo_pendiente,
        CASE
            WHEN a.importe_global > 0 THEN
                ROUND(((a.importe_global - COALESCE(a.importe_pago, 0)) / a.importe_global * 100), 2)
            ELSE 0
        END AS porcentaje_adeudo,
        CASE
            WHEN a.fecha_emision IS NOT NULL THEN
                EXTRACT(DAY FROM CURRENT_DATE - a.fecha_emision)::INTEGER
            ELSE 0
        END AS dias_vencidos,
        a.modulo,
        a.zona,
        CASE
            WHEN a.vigencia = '1' THEN 'Vigente'
            WHEN a.vigencia = '2' THEN 'Pagado'
            WHEN a.vigencia = 'P' THEN 'Pago Parcial'
            WHEN a.vigencia = '3' THEN 'Cancelado'
            ELSE 'Otro'
        END::VARCHAR(10) AS vigencia,
        COALESCE(e.nombre, 'Sin ejecutor')::VARCHAR(60) AS ejecutor_nombre,
        a.datos,
        a.observaciones,
        CASE
            WHEN COALESCE(a.importe_global, 0) - COALESCE(a.importe_pago, 0) = 0 THEN 'LIQUIDADO'
            WHEN EXTRACT(DAY FROM CURRENT_DATE - a.fecha_emision) > 90 THEN 'CRITICO'
            WHEN EXTRACT(DAY FROM CURRENT_DATE - a.fecha_emision) > 60 THEN 'ALTO'
            WHEN EXTRACT(DAY FROM CURRENT_DATE - a.fecha_emision) > 30 THEN 'MEDIO'
            ELSE 'BAJO'
        END::VARCHAR(50) AS clasificacion
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE (p_zona IS NULL OR a.zona = p_zona)
      AND (p_modulo IS NULL OR a.modulo = p_modulo)
      AND (p_fecha_desde IS NULL OR a.fecha_emision >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR a.fecha_emision <= p_fecha_hasta)
      AND (p_tipo_adeudo = 'TODOS' OR
           (p_tipo_adeudo = 'VIGENTES' AND a.vigencia = '1') OR
           (p_tipo_adeudo = 'PARCIALES' AND a.vigencia = 'P') OR
           (p_tipo_adeudo = 'LIQUIDADOS' AND a.vigencia = '2'))
      AND (COALESCE(a.importe_global, 0) - COALESCE(a.importe_pago, 0)) >= 0
    ORDER BY dias_vencidos DESC, saldo_pendiente DESC, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_listados_ade();
-- SELECT * FROM apremiossvn_listados_ade(1, NULL, 'VIGENTES', '2025-01-01', '2025-12-31');
-- SELECT * FROM apremiossvn_listados_ade(NULL, 5, 'TODOS', NULL, NULL) WHERE clasificacion = 'CRITICO';
