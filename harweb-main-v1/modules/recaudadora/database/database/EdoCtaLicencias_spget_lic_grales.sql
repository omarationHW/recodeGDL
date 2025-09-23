-- Stored Procedure: spget_lic_grales
-- Tipo: Report
-- Descripción: Obtiene los datos generales de la licencia o anuncio para el estado de cuenta/licencias.
-- Generado para formulario: EdoCtaLicencias
-- Fecha: 2025-08-27 01:16:30

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