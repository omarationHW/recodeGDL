-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOTRANS (EXACTO del archivo original)
-- Archivo: 53_SP_RECAUDADORA_DRECGOTRANS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: busca_multa_trans
-- Tipo: Report
-- Descripción: Busca folios de transmisión con recargos pendientes (completa o diferencia)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION busca_multa_trans(p_folio integer, p_tipo text)
RETURNS TABLE(
  folio integer,
  baseimpuesto numeric,
  recargos numeric,
  multas numeric,
  total numeric,
  estado text,
  id_descto integer,
  porcentaje numeric,
  observaciones text
) AS $$
BEGIN
  IF p_tipo = 'completa' THEN
    RETURN QUERY
      SELECT i.folio, i.baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
      FROM impuestoTransp i
      LEFT JOIN descrectrans dt ON dt.folio = i.folio AND dt.estado = 'V'
      WHERE i.folio = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
  ELSE
    RETURN QUERY
      SELECT i.folio, i.baseimpuesto, i.recargos, i.multas, i.total,
        COALESCE(dt.estado, 'V') AS estado,
        dt.id_descto, dt.porcentaje, dt.observaciones
      FROM diferencias_glosa i
      LEFT JOIN descrectrans dt ON dt.folio = i.foliot AND dt.estado = 'V'
      WHERE i.foliot = p_folio AND i.recargos > 0 AND (i.cvepago = 0 OR i.cvepago IS NULL);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOTRANS (EXACTO del archivo original)
-- Archivo: 53_SP_RECAUDADORA_DRECGOTRANS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: alta_descuento_trans
-- Tipo: CRUD
-- Descripción: Da de alta un descuento en recargos de transmisión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION alta_descuento_trans(
  p_folio integer,
  p_porcentaje numeric,
  p_observaciones text,
  p_autoriza integer,
  p_user text
) RETURNS TABLE(result text) AS $$
DECLARE
  v_id integer;
BEGIN
  INSERT INTO descrectrans (folio, porcentaje, fecalta, captalta, fecbaja, captbaja, estado, cvepago, autoriza, observaciones)
  VALUES (p_folio, p_porcentaje, CURRENT_DATE, p_user, NULL, NULL, 'V', NULL, p_autoriza, p_observaciones)
  RETURNING id_descto INTO v_id;
  RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: DRECGOTRANS (EXACTO del archivo original)
-- Archivo: 53_SP_RECAUDADORA_DRECGOTRANS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: get_autorizadores_trans
-- Tipo: Catalog
-- Descripción: Obtiene lista de funcionarios autorizados para descuentos en transmisión según permisos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_autorizadores_trans(p_usuario text)
RETURNS TABLE(cveautoriza integer, descripcion text, nombre text, porcentajetope integer) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM autoriza a, usuarios b, deptos d WHERE a.usuario = p_usuario AND a.num_tag IN (1319,1320) AND b.usuario = a.usuario AND d.cvedepto = b.cvedepto) THEN
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE funcionario = 'N' AND vigencia = 'V';
  ELSE
    RETURN QUERY SELECT cveautoriza, descripcion, nombre, porcentajetope FROM c_autdescrec WHERE vigencia = 'V' ORDER BY cveautoriza DESC;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

