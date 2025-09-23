-- Stored Procedure: report_unit1
-- Tipo: Report
-- Descripción: Genera el reporte de folios para una fecha/hora específica, uniendo ta_14_folios y TA_14_CVE_IMPORTe.
-- Generado para formulario: Unit1
-- Fecha: 2025-08-27 15:03:47

CREATE OR REPLACE FUNCTION report_unit1(fechora timestamp)
RETURNS TABLE (
    aso varchar,
    folio varchar,
    placa varchar,
    fecha_hora timestamp,
    estado varchar,
    clave varchar,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.aso, a.folio, a.placa, a.fecha_hora, a.estado, a.clave, b.importe
    FROM ta_14_folios a
    JOIN ta_14_cve_importe b ON a.aso = b.aso AND a.clave = b.num_clave
    WHERE a.fecha_hora = fechora
      AND a.fecha_baja = fechora
    ORDER BY a.aso, a.placa, a.folio;
END;
$$ LANGUAGE plpgsql;