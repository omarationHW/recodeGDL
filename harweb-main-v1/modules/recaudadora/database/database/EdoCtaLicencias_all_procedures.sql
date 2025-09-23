-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EdoCtaLicencias
-- Generado: 2025-08-27 01:16:30
-- Total SPs: 4
-- ============================================

-- SP 1/4: spget_lic_grales
-- Tipo: Report
-- Descripción: Obtiene los datos generales de la licencia o anuncio para el estado de cuenta/licencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spget_lic_grales(par_lic integer, par_anun integer, par_rec integer)
RETURNS TABLE (
  expression integer,
  expression_1 varchar,
  expression_2 integer,
  expression_3 integer,
  expression_4 varchar,
  expression_5 integer,
  expression_6 varchar,
  expression_7 varchar,
  expression_8 varchar,
  expression_9 varchar,
  expression_10 varchar,
  expression_11 integer,
  expression_12 varchar,
  expression_13 varchar,
  expression_14 varchar,
  expression_15 varchar,
  expression_16 integer,
  expression_17 integer,
  expression_18 varchar,
  expression_19 integer,
  expression_20 varchar,
  expression_21 float,
  expression_22 integer,
  expression_23 integer,
  expression_24 varchar,
  expression_25 date,
  expression_26 varchar,
  expression_27 integer,
  expression_28 varchar,
  expression_29 varchar,
  expression_30 varchar,
  expression_31 varchar,
  expression_32 varchar,
  expression_33 varchar,
  expression_34 varchar,
  expression_35 varchar,
  expression_36 integer,
  expression_37 varchar,
  expression_38 varchar,
  expression_39 varchar,
  expression_40 varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM v_lic_grales WHERE (id_licencia = par_lic OR id_anuncio = par_anun) AND rec = par_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: spget_lic_adeudos
-- Tipo: Report
-- Descripción: Obtiene los adeudos de una licencia o anuncio.
-- --------------------------------------------

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

-- ============================================

-- SP 3/4: spget_lic_totales
-- Tipo: Report
-- Descripción: Obtiene los totales agrupados de una licencia o anuncio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION spget_lic_totales(par_id integer, par_tipo varchar, par_no varchar)
RETURNS TABLE (
  grupo integer,
  cuenta integer,
  obliga varchar,
  concepto varchar,
  importe numeric
) AS $$
BEGIN
  IF par_tipo = 'L' THEN
    RETURN QUERY SELECT * FROM v_lic_totales WHERE id_licencia = par_id AND no = par_no;
  ELSE
    RETURN QUERY SELECT * FROM v_anun_totales WHERE id_anuncio = par_id AND no = par_no;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: odoo_adeudos_detalle_12
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos para impresión de estado de cuenta/licencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION odoo_adeudos_detalle_12(p_tipo varchar, p_numero integer, p_rec integer, p_forma_pago varchar, p_identificador integer)
RETURNS TABLE (
  norubro integer,
  noconcepto integer,
  cta_aplic integer,
  referencia varchar,
  descripcion varchar,
  monto numeric,
  acumulado numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM v_adeudos_detalle WHERE tipo = p_tipo AND numero = p_numero AND rec = p_rec AND forma_pago = p_forma_pago AND identificador = p_identificador;
END;
$$ LANGUAGE plpgsql;

-- ============================================

