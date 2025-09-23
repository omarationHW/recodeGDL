-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: doctosfrm
-- Generado: 2025-08-27 17:40:17
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_doctosfrm_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de documentos posibles para el formulario doctosfrm.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_doctosfrm_catalog()
RETURNS TABLE(codigo text, descripcion text) AS $$
BEGIN
  RETURN QUERY VALUES
    ('fotofachada', 'Fotografías de la fachada'),
    ('recibopredial', 'Recibo de predial'),
    ('ident_titular', 'Identificación titular'),
    ('ident_dueno_finca', 'Identificación del dueño de la finca'),
    ('ident_r1', 'Identificación R1 (alta de Hacienda)'),
    ('contrato_arrend', 'Contrato de arrendamiento'),
    ('solic_lic_usosuelo', 'Solicitud de licencia y uso de suelo'),
    ('solic_mod_padron', 'Solicitud de modificación al padrón y uso de suelo'),
    ('licencia_vigente', 'Licencia original vigente'),
    ('carta_policia', 'Carta de policía'),
    ('carta_poder', 'Carta de poder simple'),
    ('memoria_calculo', 'Memoria de cálculo'),
    ('poliza_responsabilidad', 'Póliza vigente de responsabilidad civil del anuncio'),
    ('acta_constitutiva', 'Acta constitutiva'),
    ('poder_notarial', 'Poder notarial'),
    ('asignacion_numeros', 'Asignación de números'),
    ('copia_licencia', 'Copia de licencia'),
    ('solic_lic_anuncio', 'Solicitud de licencia y anuncio'),
    ('solic_dictamen_anuncio', 'Solicitud de dictamen de anuncio');
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_doctosfrm_get
-- Tipo: CRUD
-- Descripción: Obtiene los documentos seleccionados para un trámite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_doctosfrm_get(p_tramite_id integer)
RETURNS TABLE(documentos text[], otro text) AS $$
BEGIN
  RETURN QUERY
    SELECT d.documentos, d.otro
    FROM doctosfrm_tramite d
    WHERE d.tramite_id = p_tramite_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_doctosfrm_save
-- Tipo: CRUD
-- Descripción: Guarda los documentos seleccionados para un trámite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_doctosfrm_save(p_tramite_id integer, p_documentos json, p_otro text)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM doctosfrm_tramite WHERE tramite_id = p_tramite_id) THEN
    UPDATE doctosfrm_tramite
      SET documentos = ARRAY(SELECT json_array_elements_text(p_documentos)), otro = p_otro
      WHERE tramite_id = p_tramite_id;
  ELSE
    INSERT INTO doctosfrm_tramite(tramite_id, documentos, otro)
      VALUES (p_tramite_id, ARRAY(SELECT json_array_elements_text(p_documentos)), p_otro);
  END IF;
  RETURN QUERY SELECT true, 'Documentos guardados';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_doctosfrm_clear
-- Tipo: CRUD
-- Descripción: Limpia la selección de documentos para un trámite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_doctosfrm_clear(p_tramite_id integer)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE doctosfrm_tramite SET documentos = ARRAY[]::text[], otro = NULL WHERE tramite_id = p_tramite_id;
  RETURN QUERY SELECT true, 'Selección limpiada';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_doctosfrm_delete
-- Tipo: CRUD
-- Descripción: Elimina un documento específico de la selección de un trámite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_doctosfrm_delete(p_tramite_id integer, p_documento text)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  UPDATE doctosfrm_tramite
    SET documentos = array_remove(documentos, p_documento)
    WHERE tramite_id = p_tramite_id;
  RETURN QUERY SELECT true, 'Documento eliminado';
END;
$$ LANGUAGE plpgsql;

-- ============================================

