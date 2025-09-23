-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ZonaAnuncio
-- Generado: 2025-08-27 19:51:59
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_zonaanuncio_get
-- Tipo: CRUD
-- Descripción: Obtiene la información de zona/subzona/recaudadora para un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonaanuncio_get(p_anuncio INTEGER)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT anuncio, zona, subzona, recaud, feccap, capturista FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;

-- ============================================

-- SP 2/6: sp_zonaanuncio_list
-- Tipo: CRUD
-- Descripción: Lista todas las zonas de un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonaanuncio_list(p_anuncio INTEGER)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT anuncio, zona, subzona, recaud, feccap, capturista FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;

-- ============================================

-- SP 3/6: sp_zonaanuncio_create
-- Tipo: CRUD
-- Descripción: Crea un registro de zona para un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonaanuncio_create(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO anuncios_zona (anuncio, zona, subzona, recaud, feccap, capturista)
  VALUES (p_anuncio, p_zona, p_subzona, p_recaud, NOW(), p_capturista);
END; $$;

-- ============================================

-- SP 4/6: sp_zonaanuncio_update
-- Tipo: CRUD
-- Descripción: Actualiza la zona/subzona/recaudadora de un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonaanuncio_update(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE anuncios_zona SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW(), capturista = p_capturista
  WHERE anuncio = p_anuncio;
END; $$;

-- ============================================

-- SP 5/6: sp_zonaanuncio_delete
-- Tipo: CRUD
-- Descripción: Elimina el registro de zona de un anuncio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonaanuncio_delete(p_anuncio INTEGER)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  DELETE FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;

-- ============================================

-- SP 6/6: sp_zonaanuncio_catalogs
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de zonas, subzonas y recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonaanuncio_catalogs()
RETURNS TABLE(tipo TEXT, id INTEGER, nombre TEXT, descripcion TEXT, cvezona INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT 'zona', cvezona, zona, cvezona || ' - ' || zona, cvezona FROM c_zonas;
  RETURN QUERY SELECT 'subzona', cvesubzona, descsubzon, cvesubzona || ' - ' || descsubzon, cvezona FROM c_subzonas;
  RETURN QUERY SELECT 'recaudadora', recaud, descripcion, recaud || ' - ' || descripcion, NULL FROM c_recaud WHERE recaud <= 5;
END; $$;

-- ============================================

