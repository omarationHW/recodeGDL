-- =====================================================
-- SP: apremiossvn_notificaciones_list
-- Descripción: Lista notificaciones de apremios con filtros avanzados
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION apremiossvn_notificaciones_list(
    p_zona INTEGER DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_estado VARCHAR(50) DEFAULT NULL,
    p_ejecutor INTEGER DEFAULT NULL
)
RETURNS TABLE (
    folio INTEGER,
    expediente VARCHAR(50),
    fecha_notificacion DATE,
    fecha_acuse DATE,
    estado VARCHAR(50),
    tipo_notificacion VARCHAR(50),
    ejecutor_nombre VARCHAR(60),
    importe_global NUMERIC(12,2),
    vigencia VARCHAR(10),
    dias_transcurridos INTEGER,
    observaciones VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        (a.zona::VARCHAR || '-' || a.modulo::VARCHAR || '-' || a.folio::VARCHAR)::VARCHAR(50) AS expediente,
        a.fecha_practicado AS fecha_notificacion,
        a.fecha_entrega1 AS fecha_acuse,
        CASE
            WHEN a.fecha_entrega1 IS NOT NULL THEN 'ACUSADO'
            WHEN a.fecha_practicado IS NOT NULL THEN 'NOTIFICADO'
            WHEN a.fecha_citatorio IS NOT NULL THEN 'CITADO'
            ELSE 'PENDIENTE'
        END::VARCHAR(50) AS estado,
        COALESCE(a.clave_practicado, 'GENERAL')::VARCHAR(50) AS tipo_notificacion,
        COALESCE(e.nombre, 'Sin ejecutor')::VARCHAR(60) AS ejecutor_nombre,
        COALESCE(a.importe_global, 0) AS importe_global,
        CASE
            WHEN a.vigencia = '1' THEN 'Vigente'
            WHEN a.vigencia = '2' THEN 'Pagado'
            WHEN a.vigencia = 'P' THEN 'Pago Parcial'
            WHEN a.vigencia = '3' THEN 'Cancelado'
            ELSE 'Otro'
        END::VARCHAR(10) AS vigencia,
        CASE
            WHEN a.fecha_practicado IS NOT NULL THEN
                EXTRACT(DAY FROM CURRENT_DATE - a.fecha_practicado)::INTEGER
            ELSE NULL
        END AS dias_transcurridos,
        a.observaciones
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE (p_zona IS NULL OR a.zona = p_zona)
      AND (p_fecha_desde IS NULL OR a.fecha_practicado >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR a.fecha_practicado <= p_fecha_hasta)
      AND (p_ejecutor IS NULL OR a.ejecutor = p_ejecutor)
      AND (p_estado IS NULL OR
           CASE
               WHEN a.fecha_entrega1 IS NOT NULL THEN 'ACUSADO'
               WHEN a.fecha_practicado IS NOT NULL THEN 'NOTIFICADO'
               WHEN a.fecha_citatorio IS NOT NULL THEN 'CITADO'
               ELSE 'PENDIENTE'
           END = p_estado)
    ORDER BY a.fecha_practicado DESC NULLS LAST, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM apremiossvn_notificaciones_list();
-- SELECT * FROM apremiossvn_notificaciones_list(1, '2025-01-01', '2025-12-31', 'NOTIFICADO', NULL);
-- SELECT * FROM apremiossvn_notificaciones_list(NULL, NULL, NULL, 'ACUSADO', NULL);
