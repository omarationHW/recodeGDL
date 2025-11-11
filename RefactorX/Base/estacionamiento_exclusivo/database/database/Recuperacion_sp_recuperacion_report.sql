-- =====================================================
-- SP: sp_recuperacion_report
-- Descripción: Reporte de recuperación de adeudos por tipo
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_recuperacion_report(
    p_tipo VARCHAR(50)
)
RETURNS TABLE (
    folio INTEGER,
    importe NUMERIC(12,2),
    importe_recuperado NUMERIC(12,2),
    porcentaje NUMERIC(5,2),
    fecha_emision DATE,
    fecha_pago DATE,
    modulo SMALLINT,
    zona SMALLINT,
    vigencia VARCHAR(10),
    ejecutor_nombre VARCHAR(60),
    dias_recuperacion INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        COALESCE(a.importe_global, 0) AS importe,
        COALESCE(a.importe_pago, 0) AS importe_recuperado,
        CASE
            WHEN a.importe_global > 0 THEN
                ROUND((a.importe_pago / a.importe_global * 100), 2)
            ELSE 0
        END AS porcentaje,
        a.fecha_emision,
        a.fecha_pago,
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
        CASE
            WHEN a.fecha_pago IS NOT NULL AND a.fecha_emision IS NOT NULL THEN
                EXTRACT(DAY FROM a.fecha_pago - a.fecha_emision)::INTEGER
            ELSE NULL
        END AS dias_recuperacion
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE
        CASE
            WHEN p_tipo = 'TODOS' THEN TRUE
            WHEN p_tipo = 'PAGADOS' THEN a.vigencia IN ('2', 'P')
            WHEN p_tipo = 'VIGENTES' THEN a.vigencia = '1'
            WHEN p_tipo = 'CANCELADOS' THEN a.vigencia = '3'
            ELSE TRUE
        END
    ORDER BY a.fecha_pago DESC NULLS LAST, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_recuperacion_report('TODOS');
-- SELECT * FROM sp_recuperacion_report('PAGADOS');
-- SELECT * FROM sp_recuperacion_report('VIGENTES') WHERE dias_recuperacion > 30;
