-- Stored Procedure: spget_lic_adeudos
-- Tipo: Report
-- Descripción: Obtiene los adeudos de una licencia o anuncio.
-- Generado para formulario: EdoCtaLicencias
-- Fecha: 2025-08-27 01:16:30

CREATE OR REPLACE FUNCTION spget_lic_adeudos(par_id integer, par_tipo varchar)
RETURNS TABLE (
  id_licencia integer,
  axo integer,
  licencia integer,
  anuncio integer,
  formas numeric,
  derechos numeric,
  desc_derechos numeric,
  recargos numeric,
  desc_recargos numeric,
  gastos numeric,
  multas numeric,
  saldo numeric,
  concepto varchar,
  bloq varchar
) AS $$
BEGIN
  IF par_tipo = 'L' THEN
    RETURN QUERY SELECT * FROM v_lic_adeudos WHERE id_licencia = par_id;
  ELSE
    RETURN QUERY SELECT * FROM v_anun_adeudos WHERE id_anuncio = par_id;
  END IF;
END;
$$ LANGUAGE plpgsql;