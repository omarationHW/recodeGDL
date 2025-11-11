-- =====================================================
-- SP: apremiossvn_expedientes_list
-- Descripción: Lista expedientes de apremios con filtros múltiples
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_expedientes_list(
    p_zona INTEGER DEFAULT NULL,
    p_modulo INTEGER DEFAULT NULL,
    p_vigencia VARCHAR(10) DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_ejecutor INTEGER DEFAULT NULL
)
RETURNS TABLE (
    folio INTEGER,
    expediente VARCHAR(50),
    fecha_emision DATE,
    fecha_practicado DATE,
    importe_global NUMERIC(12,2),
    importe_pago NUMERIC(12,2),
    saldo NUMERIC(12,2),
    vigencia VARCHAR(10),
    ejecutor_nombre VARCHAR(60),
    modulo SMALLINT,
    zona SMALLINT,
    datos VARCHAR,
    observaciones VARCHAR,
    clave_practicado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        (a.zona::VARCHAR || '-' || a.modulo::VARCHAR || '-' || a.folio::VARCHAR)::VARCHAR(50) AS expediente,
        a.fecha_emision,
        a.fecha_practicado,
        COALESCE(a.importe_global, 0) AS importe_global,
        COALESCE(a.importe_pago, 0) AS importe_pago,
        COALESCE(a.importe_global, 0) - COALESCE(a.importe_pago, 0) AS saldo,
        CASE
            WHEN a.vigencia = '1' THEN 'Vigente'
            WHEN a.vigencia = '2' THEN 'Pagado'
            WHEN a.vigencia = 'P' THEN 'Pago Parcial'
            WHEN a.vigencia = '3' THEN 'Cancelado'
            ELSE 'Otro'
        END::VARCHAR(10) AS vigencia,
        COALESCE(e.nombre, 'Sin ejecutor')::VARCHAR(60) AS ejecutor_nombre,
        a.modulo,
        a.zona,
        a.datos,
        a.observaciones,
        a.clave_practicado
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE (p_zona IS NULL OR a.zona = p_zona)
      AND (p_modulo IS NULL OR a.modulo = p_modulo)
      AND (p_vigencia IS NULL OR a.vigencia = p_vigencia)
      AND (p_fecha_desde IS NULL OR a.fecha_emision >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR a.fecha_emision <= p_fecha_hasta)
      AND (p_ejecutor IS NULL OR a.ejecutor = p_ejecutor)
    ORDER BY a.fecha_emision DESC, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_expedientes_list();
-- SELECT * FROM apremiossvn_expedientes_list(1, NULL, '1', '2025-01-01', '2025-12-31', NULL);
-- SELECT * FROM apremiossvn_expedientes_list(NULL, 5, NULL, NULL, NULL, NULL);
