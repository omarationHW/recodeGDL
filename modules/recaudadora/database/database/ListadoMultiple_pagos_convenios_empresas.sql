-- Stored Procedure: pagos_convenios_empresas
-- Tipo: Report
-- Descripción: Obtiene pagos de convenios por empresa y rango de fechas
-- Generado para formulario: ListadoMultiple
-- Fecha: 2025-08-27 12:49:10

CREATE OR REPLACE FUNCTION pagos_convenios_empresas(
  pejec integer,
  pftrab date,
  pfpagod date,
  pfpagoh date
)
RETURNS TABLE(
  cvecuenta integer,
  cuenta varchar,
  foliorecibo varchar,
  fecha_pago date,
  importe_pago numeric,
  convenio varchar,
  fecha_convenio date,
  parc_ini integer,
  parc_fin integer,
  cvereq integer,
  folioreq integer,
  fecha_req date,
  vigencia varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT cvecuenta, cuenta, foliorecibo, fecha_pago, importe_pago, convenio, fecha_convenio, parc_ini, parc_fin, cvereq, folioreq, fecha_req, vigencia
  FROM pagos_convenios_empresas_view
  WHERE cveejecutor = pejec
    AND fecha_trabajo = pftrab
    AND fecha_pago BETWEEN pfpagod AND pfpagoh;
END;
$$ LANGUAGE plpgsql;