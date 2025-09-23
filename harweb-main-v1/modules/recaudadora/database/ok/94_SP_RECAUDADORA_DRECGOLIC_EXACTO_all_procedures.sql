-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOLIC (EXACTO del archivo original)
-- Archivo: 94_SP_RECAUDADORA_DRECGOLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
-- ============================================

-- SP 1/9: sp_busca_licencia
-- Tipo: Catalog
-- Descripción: Busca licencia por folio y tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_licencia(p_folio INTEGER, p_tipo VARCHAR) RETURNS TABLE(
  id_licencia INTEGER,
  licencia INTEGER,
  min SMALLINT,
  max SMALLINT,
  propietario VARCHAR
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia,
      (SELECT MIN(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.recargos>0 AND d.cvepago=0) AS min,
      (SELECT MAX(d.axo) FROM detsal_lic d WHERE d.id_licencia=l.id_licencia AND d.recargos>0 AND d.cvepago=0 AND d.axo<=EXTRACT(YEAR FROM CURRENT_DATE)) AS max,
      l.propietario
    FROM public l, saldos_lic s
    WHERE l.id_licencia=s.id_licencia AND l.licencia=p_folio AND (s.recargos>0 OR s.multas>0) AND l.vigente='V' AND l.bloqueado=0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOLIC (EXACTO del archivo original)
-- Archivo: 94_SP_RECAUDADORA_DRECGOLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
-- ============================================

-- SP 3/9: sp_busca_descuento
-- Tipo: Catalog
-- Descripción: Busca descuentos de recargos/multas para licencia/anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busca_descuento(p_id_gral INTEGER, p_tipo VARCHAR) RETURNS TABLE(
  id_descto INTEGER,
  tipo VARCHAR,
  licencia INTEGER,
  porcentaje SMALLINT,
  fecalta DATE,
  captalta VARCHAR,
  fecbaja DATE,
  captbaja VARCHAR,
  estado VARCHAR,
  cvepago INTEGER,
  axoini INTEGER,
  axofin INTEGER,
  autoriza SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT id_descto, tipo, licencia, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, axoini, axofin, autoriza
    FROM descreclic
    WHERE licencia=p_id_gral AND tipo=p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOLIC (EXACTO del archivo original)
-- Archivo: 94_SP_RECAUDADORA_DRECGOLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
-- ============================================

-- SP 5/9: sp_alta_desc_multa
-- Tipo: CRUD
-- Descripción: Alta de descuento de multa para licencia/anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_alta_desc_multa(
  p_tipo VARCHAR, p_licencia INTEGER, p_porcentaje SMALLINT, p_usuario VARCHAR, p_autoriza SMALLINT, p_minmax VARCHAR, p_axoini INTEGER, p_axofin INTEGER
) RETURNS TABLE(id_descto INTEGER) AS $$
DECLARE
  v_id INTEGER;
BEGIN
  INSERT INTO descmultalic (tipo, id_licanun, porcentaje, fecalta, useralta, fecbaja, userbaja, vigencia, cvepago, folio, autoriza, fecact, useract)
  VALUES (p_tipo, p_licencia, p_porcentaje, CURRENT_DATE, p_usuario, NULL, NULL, 'V', NULL, NULL, p_autoriza, CURRENT_DATE, p_usuario)
  RETURNING id_descto INTO v_id;
  RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOLIC (EXACTO del archivo original)
-- Archivo: 94_SP_RECAUDADORA_DRECGOLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
-- ============================================

-- SP 7/9: sp_baja_desc_multa
-- Tipo: CRUD
-- Descripción: Cancela descuento de multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_baja_desc_multa(p_id_descto INTEGER, p_usuario VARCHAR) RETURNS VOID AS $$
BEGIN
  UPDATE descmultalic SET vigencia='C', fecbaja=CURRENT_DATE, userbaja=p_usuario WHERE id_descto=p_id_descto;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOLIC (EXACTO del archivo original)
-- Archivo: 94_SP_RECAUDADORA_DRECGOLIC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 9 (EXACTO)
-- ============================================

-- SP 9/9: sp_consulta_funcionarios
-- Tipo: Catalog
-- Descripción: Consulta funcionarios autorizados para descuentos de recargo o multa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_consulta_funcionarios(p_tipo VARCHAR) RETURNS TABLE(
  cveautoriza INTEGER,
  descripcion VARCHAR,
  nombre VARCHAR,
  porcentajetope INTEGER
) AS $$
BEGIN
  IF p_tipo = 'recargo' THEN
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE vigencia='V' ORDER BY cveautoriza DESC;
  ELSE
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescmul WHERE vigencia='V' ORDER BY cveautoriza DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

