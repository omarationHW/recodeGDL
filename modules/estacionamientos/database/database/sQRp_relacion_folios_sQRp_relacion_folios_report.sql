-- Stored Procedure: sQRp_relacion_folios_report
-- Tipo: Report
-- Descripción: Genera el reporte de relación de folios de estacionómetros según el tipo de fecha y la fecha proporcionada.
-- Generado para formulario: sQRp_relacion_folios
-- Fecha: 2025-08-27 14:58:16

-- sQRp_relacion_folios_report(opcion integer, fecha date)
-- opcion: 1=fecha_folio, 2=fecha_alta, 3=fecha_baja pago, 4=fecha_baja cancelación
CREATE OR REPLACE FUNCTION sQRp_relacion_folios_report(opcion integer, fecha date)
RETURNS TABLE(
    axo smallint,
    folio integer,
    placa varchar,
    fecha_folio date,
    estado smallint,
    infraccion smallint,
    tarifa numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.axo, a.folio, a.placa, a.fecha_folio, a.estado, a.infraccion, b.tarifa
    FROM ta14_folios_adeudo a
    JOIN ta14_tarifas b ON a.infraccion = b.num_clave AND a.fecha_folio BETWEEN b.fecha_inicial AND b.fecha_fin
    WHERE (
        (opcion = 1 AND a.fecha_folio = fecha)
        OR (opcion = 2 AND a.fecha_alta = fecha)
        OR (opcion = 3 AND a.fecha_baja >= fecha AND a.fecha_baja <= (fecha + INTERVAL '1 day') AND a.fecha_pago IS NOT NULL)
        OR (opcion = 4 AND a.fecha_baja::date = fecha AND a.cve_mov = 'C')
    )
    ORDER BY a.axo, a.placa, a.folio;
END;
$$ LANGUAGE plpgsql;
