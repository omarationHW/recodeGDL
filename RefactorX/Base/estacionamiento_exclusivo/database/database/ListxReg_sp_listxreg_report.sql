-- =====================================================
-- SP: sp_listxreg_report
-- Descripción: Reporte de apremios por región/zona
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-10
-- Base: estacionamiento_exclusivo
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION sp_listxreg_report(
    p_region VARCHAR(50)
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
    zona_apremio SMALLINT,
    observaciones VARCHAR,
    fecha_pago DATE,
    clave_practicado VARCHAR
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
        a.zona_apremio,
        a.observaciones,
        a.fecha_pago,
        a.clave_practicado
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores e ON a.ejecutor = e.cve_eje AND a.zona = e.id_rec
    WHERE (p_region = 'TODAS' OR a.zona::VARCHAR = p_region OR a.zona_apremio::VARCHAR = p_region)
    ORDER BY a.zona, a.folio;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
-- SELECT * FROM sp_listxreg_report('TODAS');
-- SELECT * FROM sp_listxreg_report('1');
-- SELECT * FROM sp_listxreg_report('5');
