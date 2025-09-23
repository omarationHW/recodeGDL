-- Stored Procedure: spget_lic_adeudos
-- Tipo: Report
-- Descripción: Obtiene los adeudos de una licencia o anuncio para trámite de baja
-- Generado para formulario: TramiteBajaLic
-- Fecha: 2025-08-26 18:22:43

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
  gastos numeric,
  multas numeric,
  actualizacion numeric,
  saldo numeric,
  concepto varchar,
  bloq varchar
) AS $$
BEGIN
  IF v_tipo = 'L' THEN
    RETURN QUERY SELECT id_licencia, axo, licencia, 0, formas, desc_formas, derechos, desc_derechos, derechos2, recargos, desc_recargos, gastos, multas, actualizacion, saldo, concepto, bloq
    FROM detsal_lic WHERE id_licencia = v_id AND cvepago = 0;
  ELSE
    RETURN QUERY SELECT id_licencia, axo, 0, id_anuncio, formas, desc_formas, derechos, desc_derechos, derechos2, recargos, desc_recargos, gastos, multas, actualizacion, saldo, concepto, bloq
    FROM detsal_lic WHERE id_anuncio = v_id AND cvepago = 0;
  END IF;
END;
$$ LANGUAGE plpgsql;