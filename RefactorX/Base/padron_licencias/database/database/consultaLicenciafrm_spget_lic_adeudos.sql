-- Stored Procedure: spget_lic_adeudos
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de una licencia (o anuncio) por año, incluyendo derechos, recargos, formas, etc.
-- Generado para formulario: consultaLicenciafrm
-- Fecha: 2025-08-27 17:25:29

CREATE OR REPLACE FUNCTION spget_lic_adeudos(v_id integer, v_tipo varchar)
RETURNS TABLE(
  id_licencia integer,
  axo integer,
  licencia integer,
  anuncio integer,
  formas numeric,
  desc_formas numeric,
  derechos numeric,
  desc_derechos numeric,
  derechos2 numeric,
  recargos numeric,
  desc_recargos numeric,
  actualizacion numeric,
  gastos numeric,
  multas numeric,
  saldo numeric,
  concepto varchar,
  bloq varchar
) AS $$
BEGIN
  IF v_tipo = 'L' THEN
    RETURN QUERY
      SELECT d.id_licencia, d.axo, d.licencia, d.anuncio, d.formas, d.desc_formas, d.derechos, d.desc_derechos, d.derechos2, d.recargos, d.desc_recargos, d.actualizacion, d.gastos, d.multas, d.saldo, d.concepto, d.bloq
      FROM detsal_lic d
      WHERE d.id_licencia = v_id AND d.cvepago = 0;
  ELSIF v_tipo = 'A' THEN
    RETURN QUERY
      SELECT d.id_licencia, d.axo, d.licencia, d.anuncio, d.formas, d.desc_formas, d.derechos, d.desc_derechos, d.derechos2, d.recargos, d.desc_recargos, d.actualizacion, d.gastos, d.multas, d.saldo, d.concepto, d.bloq
      FROM detsal_lic d
      WHERE d.anuncio = v_id AND d.cvepago = 0;
  END IF;
END;
$$ LANGUAGE plpgsql;