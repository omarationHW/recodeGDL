-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONAANUNCIO (EXACTO del archivo original)
-- Archivo: 36_SP_LICENCIAS_ZONAANUNCIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONAANUNCIO (EXACTO del archivo original)
-- Archivo: 36_SP_LICENCIAS_ZONAANUNCIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONAANUNCIO (EXACTO del archivo original)
-- Archivo: 36_SP_LICENCIAS_ZONAANUNCIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONAANUNCIO (EXACTO del archivo original)
-- Archivo: 36_SP_LICENCIAS_ZONAANUNCIO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

