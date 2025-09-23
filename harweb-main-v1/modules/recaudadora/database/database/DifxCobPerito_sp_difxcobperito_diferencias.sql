-- Stored Procedure: sp_difxcobperito_diferencias
-- Tipo: Report
-- Descripción: Obtiene las diferencias por cobrar de un perito en el periodo y vigencia indicada.
-- Generado para formulario: DifxCobPerito
-- Fecha: 2025-08-27 00:28:12

CREATE OR REPLACE FUNCTION sp_difxcobperito_diferencias(p_noperito INTEGER, p_fecha1 DATE, p_fecha2 DATE, p_vigencia VARCHAR)
RETURNS TABLE(
  id INTEGER,
  foliot INTEGER,
  cvecuenta INTEGER,
  fecha_alta DATE,
  usu_alta VARCHAR,
  vigencia VARCHAR,
  fecha_baja DATE,
  usu_baja VARCHAR,
  cvepago INTEGER,
  fecha_pago DATE,
  fecha_actual DATE,
  usu_act VARCHAR,
  importe_base NUMERIC,
  recargos NUMERIC,
  multas NUMERIC,
  multasext NUMERIC,
  imp_ot NUMERIC,
  gastos NUMERIC,
  total NUMERIC,
  observaciones VARCHAR,
  fecha_rec DATE,
  noperito INTEGER,
  folio_glosa INTEGER,
  recaud INTEGER,
  urbrus VARCHAR,
  cuenta INTEGER,
  avaluo INTEGER,
  quienrep INTEGER,
  nombredepto VARCHAR
) AS $$
BEGIN
  RETURN QUERY
    SELECT d.id, d.foliot, d.cvecuenta, d.fecha_alta, d.usu_alta, d.vigencia, d.fecha_baja, d.usu_baja, d.cvepago, d.fecha_pago, d.fecha_actual, d.usu_act,
           d.importe_base, d.recargos, d.multas, d.multasext, d.imp_ot, d.gastos, d.total, d.observaciones, d.fecha_rec, d.noperito, d.folio_glosa,
           c.recaud, c.urbrus, c.cuenta, d.avaluo, d.quienrep, e.nombredepto
    FROM diferencias_glosa d
    JOIN convcta c ON d.cvecuenta = c.cvecuenta
    JOIN deptos e ON d.quienrep = e.cvedepto
    WHERE d.noperito = p_noperito
      AND d.fecha_alta BETWEEN p_fecha1 AND p_fecha2
      AND d.vigencia = p_vigencia;
END;
$$ LANGUAGE plpgsql;