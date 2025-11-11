-- =====================================================
-- SP: sp_listxfec_report (versión simplificada)
-- Descripción: Reporte de apremios por rango de fechas (versión simple)
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- Nota: Ya existe una versión más compleja en ListxFec_sp_listxFec_report.sql
--       Esta es una versión simplificada para casos básicos
-- =====================================================

CREATE OR REPLACE FUNCTION sp_listxfec_report_simple(
    p_desde DATE,
    p_hasta DATE
)
RETURNS TABLE (
    folio INTEGER,
    fecha_emision DATE,
    fecha_practicado DATE,
    importe_global NUMERIC(12,2),
    importe_pago NUMERIC(12,2),
    vigencia VARCHAR(10),
    ejecutor_nombre VARCHAR(60),
    modulo SMALLINT,
    zona SMALLINT,
    observaciones VARCHAR,
    fecha_pago DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        a.fecha_emision,
        a.fecha_practicado,
        COALESCE(a.importe_global, 0) AS importe_global,
        COALESCE(a.importe_pago, 0) AS importe_pago,
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
        a.observaciones,
        a.fecha_pago
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE a.fecha_emision BETWEEN p_desde AND p_hasta
    ORDER BY a.fecha_emision DESC, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_listxfec_report_simple('2025-01-01', '2025-12-31');
-- SELECT * FROM sp_listxfec_report_simple('2025-01-01', CURRENT_DATE) WHERE vigencia = 'Vigente';

-- NOTA: Para una versión más completa con filtros dinámicos por tipo de fecha,
-- usar sp_listxFec_report() que ya existe en el sistema.
