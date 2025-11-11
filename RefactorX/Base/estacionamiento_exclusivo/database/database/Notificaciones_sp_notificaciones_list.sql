-- =====================================================
-- SP: sp_notificaciones_list
-- Descripción: Lista notificaciones de apremios por rango de fechas
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_notificaciones_list(
    p_desde DATE,
    p_hasta DATE
)
RETURNS TABLE (
    folio INTEGER,
    fecha_notificacion DATE,
    estado_notificacion VARCHAR(50),
    tipo VARCHAR(50),
    fecha_practicado DATE,
    fecha_citatorio DATE,
    fecha_entrega1 DATE,
    ejecutor_nombre VARCHAR(60),
    importe_global NUMERIC(12,2),
    vigencia VARCHAR(10),
    observaciones VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        a.fecha_practicado AS fecha_notificacion,
        CASE
            WHEN a.fecha_practicado IS NOT NULL THEN 'Notificado'
            WHEN a.fecha_citatorio IS NOT NULL THEN 'Citado'
            WHEN a.fecha_entrega1 IS NOT NULL THEN 'Entregado'
            ELSE 'Pendiente'
        END::VARCHAR(50) AS estado_notificacion,
        CASE
            WHEN a.clave_practicado IS NOT NULL THEN a.clave_practicado
            ELSE 'General'
        END::VARCHAR(50) AS tipo,
        a.fecha_practicado,
        a.fecha_citatorio,
        a.fecha_entrega1,
        COALESCE(e.nombre, 'Sin ejecutor')::VARCHAR(60) AS ejecutor_nombre,
        COALESCE(a.importe_global, 0) AS importe_global,
        CASE
            WHEN a.vigencia = '1' THEN 'Vigente'
            WHEN a.vigencia = '2' THEN 'Pagado'
            WHEN a.vigencia = 'P' THEN 'Pago Parcial'
            WHEN a.vigencia = '3' THEN 'Cancelado'
            ELSE 'Otro'
        END::VARCHAR(10) AS vigencia,
        a.observaciones
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE (a.fecha_practicado BETWEEN p_desde AND p_hasta
           OR a.fecha_citatorio BETWEEN p_desde AND p_hasta
           OR a.fecha_entrega1 BETWEEN p_desde AND p_hasta)
    ORDER BY a.fecha_practicado DESC, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_notificaciones_list('2025-01-01', '2025-12-31');
-- SELECT * FROM sp_notificaciones_list('2025-01-01', CURRENT_DATE) WHERE estado_notificacion = 'Notificado';
