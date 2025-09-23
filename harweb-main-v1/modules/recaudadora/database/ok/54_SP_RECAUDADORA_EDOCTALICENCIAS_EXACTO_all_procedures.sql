-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EDOCTALICENCIAS (EXACTO del archivo original)
-- Archivo: 54_SP_RECAUDADORA_EDOCTALICENCIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: spget_lic_grales
-- Tipo: Report
-- Descripción: Obtiene los datos generales de la licencia o anuncio para el estado de cuenta/public.
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EDOCTALICENCIAS (EXACTO del archivo original)
-- Archivo: 54_SP_RECAUDADORA_EDOCTALICENCIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: EDOCTALICENCIAS (EXACTO del archivo original)
-- Archivo: 54_SP_RECAUDADORA_EDOCTALICENCIAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

