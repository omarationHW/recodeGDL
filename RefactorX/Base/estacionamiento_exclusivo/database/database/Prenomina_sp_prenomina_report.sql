-- Stored Procedure: sp_prenomina_report
-- Tipo: Report
-- Descripción: Genera el reporte de prenómina de ejecutores entre fechas y recaudadoras.
-- Generado para formulario: Prenomina
-- Fecha: 2025-08-27 14:21:26

CREATE OR REPLACE FUNCTION sp_prenomina_report(
  p_fecha_desde date,
  p_fecha_hasta date,
  p_recaudadora_desde smallint,
  p_recaudadora_hasta smallint
)
RETURNS TABLE(
  zona smallint,
  ejecutor smallint,
  fec_rfc date,
  ini_rfc varchar,
  hom_rfc varchar,
  nombre varchar,
  gastos numeric,
  cuantos float,
  recaudadora varchar,
  zona_1 varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      b.id_rec as zona,
      a.ejecutor,
      b.fec_rfc,
      b.ini_rfc,
      b.hom_rfc,
      b.nombre,
      SUM(a.importe_gastos) as gastos,
      COUNT(*) as cuantos,
      c.recaudadora,
      d.zona as zona_1
    FROM ta_15_apremios a
    JOIN ta_15_ejecutores b ON a.ejecutor = b.id_ejecutor
    JOIN padron_licencias.comun.ta_12_recaudadoras c ON b.id_rec = c.id_rec
    JOIN padron_licencias.comun.ta_12_zonas d ON c.id_zona = d.id_zona
    WHERE a.fecha_pago >= p_fecha_desde
      AND a.fecha_pago <= p_fecha_hasta
      AND a.vigencia = '2'
      AND a.clave_practicado = 'P'
      AND b.id_rec BETWEEN p_recaudadora_desde AND p_recaudadora_hasta
    GROUP BY b.id_rec, a.ejecutor, b.fec_rfc, b.ini_rfc, b.hom_rfc, b.nombre, c.recaudadora, d.zona
    ORDER BY b.id_rec, a.ejecutor;
END;
$$ LANGUAGE plpgsql;