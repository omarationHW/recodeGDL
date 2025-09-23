-- Stored Procedure: sp_report_calcomanias
-- Tipo: Report
-- Descripción: Reporte de calcomanías expedidas entre dos fechas de captura.
-- Generado para formulario: sfrm_reportescalco
-- Fecha: 2025-08-27 14:22:02

CREATE OR REPLACE FUNCTION sp_report_calcomanias(fecha1 date, fecha2 date)
RETURNS TABLE(
  nompropietario text,
  placa varchar(10),
  num_calco integer,
  fecha_inicial date,
  fecha_fin date,
  status varchar(1),
  turno varchar(1),
  fecha_pago date,
  reca smallint,
  caja varchar(2),
  operacion integer,
  importe_pago numeric,
  fec_cap date,
  usu_inicial integer,
  vigencia varchar(9),
  operacion_caja text
)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT
      TRIM(COALESCE(c.ap_pater, '.')) || ' ' || TRIM(COALESCE(c.ap_mater, '.')) || ' ' || TRIM(COALESCE(c.nombre, '.')) AS nompropietario,
      a.placa,
      a.num_calco,
      a.fecha_inicial,
      a.fecha_fin,
      a.status,
      a.turno,
      a.fecha_pago,
      a.reca,
      a.caja,
      a.operacion,
      a.importe_pago,
      a.fec_cap,
      a.usu_inicial,
      CASE
        WHEN a.status = 'A' THEN 'ANUAL'
        WHEN a.status = 'S' THEN 'SEMESTRAL'
        WHEN a.status = 'T' THEN 'SEMESTRAL'
        ELSE 'SEMESTRAL'
      END AS vigencia,
      (a.fecha_pago::text || '-' || a.reca::text || '-' || TRIM(a.caja) || '-' || a.operacion::text) AS operacion_caja
    FROM ta14_calcomanias a
    JOIN ta14_personas c ON a.propietario = c.id_esta_persona
    WHERE a.fec_cap BETWEEN fecha1 AND fecha2
    ORDER BY a.num_calco;
END;
$$;