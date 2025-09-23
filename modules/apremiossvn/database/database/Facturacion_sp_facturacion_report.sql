-- Stored Procedure: sp_facturacion_report
-- Tipo: Report
-- Descripción: Genera el reporte de facturación para un rango de folios, módulo y recaudadora (puede usarse para PDF/Excel).
-- Generado para formulario: Facturacion
-- Fecha: 2025-08-27 13:48:14

CREATE OR REPLACE FUNCTION sp_facturacion_report(
    p_modulo integer,
    p_rec integer,
    p_fol1 integer,
    p_fol2 integer
)
RETURNS TABLE(
    folio integer,
    nombre text,
    importe_global numeric,
    importe_multa numeric,
    importe_recargo numeric,
    importe_gastos numeric,
    fecha_emision date,
    vigencia text
    -- Agrega más columnas según necesidad
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.folio,
        COALESCE(b.nombre, '') AS nombre,
        a.importe_global,
        a.importe_multa,
        a.importe_recargo,
        a.importe_gastos,
        a.fecha_emision,
        a.vigencia
    FROM ta_15_apremios a
    LEFT JOIN ta_15_ejecutores b ON a.ejecutor = b.cve_eje AND a.zona = b.id_rec
    WHERE a.modulo = p_modulo
      AND a.zona = p_rec
      AND a.folio BETWEEN p_fol1 AND p_fol2
    ORDER BY a.folio;
END;
$$ LANGUAGE plpgsql;