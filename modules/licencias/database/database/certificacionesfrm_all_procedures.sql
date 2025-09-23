-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: certificacionesfrm
-- Generado: 2025-08-27 17:08:49
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_certificaciones_list
-- Tipo: Report
-- Descripción: Obtiene listado de certificaciones por tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_list(p_tipo TEXT)
RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id, axo, folio, id_licencia, partidapago, observacion, vigente, feccap, capturista, tipo FROM certificaciones WHERE tipo = p_tipo ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_certificaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva certificación y actualiza el folio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_create(p_tipo TEXT, p_id_licencia INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS INT AS $$
DECLARE
  new_folio INT;
  new_id INT;
BEGIN
  SELECT certificacion INTO new_folio FROM parametros_lic;
  new_folio := new_folio + 1;
  UPDATE parametros_lic SET certificacion = new_folio;
  INSERT INTO certificaciones(tipo, id_licencia, axo, folio, vigente, observacion, partidapago, feccap, capturista)
  VALUES (p_tipo, p_id_licencia, EXTRACT(YEAR FROM CURRENT_DATE), new_folio, 'V', p_observacion, p_partidapago, CURRENT_DATE, p_capturista)
  RETURNING id INTO new_id;
  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_certificaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza una certificación existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_update(p_id INT, p_observacion TEXT, p_partidapago TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET observacion = p_observacion, partidapago = p_partidapago, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_certificaciones_cancel
-- Tipo: CRUD
-- Descripción: Cancela una certificación (marca como no vigente y guarda motivo)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_cancel(p_id INT, p_motivo TEXT, p_capturista TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE certificaciones SET vigente = 'C', observacion = p_motivo, capturista = p_capturista WHERE id = p_id;
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_certificaciones_search
-- Tipo: Report
-- Descripción: Búsqueda avanzada de certificaciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_search(
  p_axo INT DEFAULT NULL, p_folio INT DEFAULT NULL, p_id_licencia INT DEFAULT NULL, p_feccap_ini DATE DEFAULT NULL, p_feccap_fin DATE DEFAULT NULL, p_tipo TEXT DEFAULT NULL
) RETURNS TABLE(id INT, axo INT, folio INT, id_licencia INT, partidapago TEXT, observacion TEXT, vigente TEXT, feccap DATE, capturista TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY SELECT * FROM certificaciones
    WHERE (p_axo IS NULL OR axo = p_axo)
      AND (p_folio IS NULL OR folio = p_folio)
      AND (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_feccap_ini IS NULL OR feccap >= p_feccap_ini)
      AND (p_feccap_fin IS NULL OR feccap <= p_feccap_fin)
      AND (p_tipo IS NULL OR tipo = p_tipo)
    ORDER BY axo DESC, folio DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_certificaciones_print
-- Tipo: Report
-- Descripción: Devuelve los datos de la certificación y pagos para impresión
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_certificaciones_print(p_id INT)
RETURNS TABLE(certificacion JSON, licencia JSON, pagos JSON) AS $$
DECLARE
  cert JSON;
  lic JSON;
  pgs JSON;
BEGIN
  SELECT row_to_json(c) INTO cert FROM (SELECT * FROM certificaciones WHERE id = p_id) c;
  SELECT row_to_json(l) INTO lic FROM (SELECT * FROM licencias WHERE id_licencia = (SELECT id_licencia FROM certificaciones WHERE id = p_id)) l;
  SELECT json_agg(row_to_json(p)) INTO pgs FROM (SELECT * FROM pagos WHERE cvecuenta = (SELECT id_licencia FROM certificaciones WHERE id = p_id) AND cveconcepto = 8 ORDER BY fecha DESC, hora DESC) p;
  RETURN QUERY SELECT cert, lic, pgs;
END;
$$ LANGUAGE plpgsql;

-- ============================================

