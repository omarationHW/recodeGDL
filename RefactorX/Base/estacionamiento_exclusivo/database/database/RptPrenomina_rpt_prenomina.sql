-- Stored Procedure: rpt_prenomina
-- Tipo: Report
-- Descripción: Devuelve el listado de pagos a ejecutores de la oficina, agrupado por zona, ejecutor, RFC, nombre, recaudadora y zona_1, con sumas de importe_pago y conteo de requerimientos.
-- Generado para formulario: RptPrenomina
-- Fecha: 2025-08-27 14:58:17

CREATE OR REPLACE FUNCTION rpt_prenomina(
    fec1 DATE,
    fec2 DATE,
    recaud SMALLINT,
    recaud1 SMALLINT
)
RETURNS TABLE (
    zona SMALLINT,
    ejecutor SMALLINT,
    ini_rfc VARCHAR(4),
    fec_rfc DATE,
    hom_rfc VARCHAR(3),
    nombre VARCHAR(60),
    gastos NUMERIC(18,2),
    cuantos FLOAT,
    recaudadora VARCHAR(32),
    zona_1 VARCHAR(32)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.zona,
        a.ejecutor,
        b.ini_rfc,
        b.fec_rfc,
        b.hom_rfc,
        b.nombre,
        SUM(a.importe_pago) AS gastos,
        COUNT(*) AS cuantos,
        c.recaudadora,
        d.zona AS zona_1
    FROM ta_15_apremios a
    JOIN ta_15_ejecutores b ON a.ejecutor = b.cve_eje
    JOIN padron_licencias.comun.ta_12_recaudadoras c ON a.zona = c.id_rec AND b.id_rec = c.id_rec
    JOIN padron_licencias.comun.ta_12_zonas d ON c.id_zona = d.id_zona
    WHERE (a.fecha_pago >= fec1 AND a.fecha_pago <= fec2)
      AND (a.vigencia = '2' OR a.vigencia = 'P')
      AND a.clave_practicado = 'P'
      AND (b.id_rec >= recaud AND b.id_rec <= recaud1)
    GROUP BY a.zona, a.ejecutor, b.ini_rfc, b.fec_rfc, b.hom_rfc, b.nombre, c.recaudadora, d.zona
    ORDER BY a.zona, a.ejecutor;
END;
$$ LANGUAGE plpgsql;