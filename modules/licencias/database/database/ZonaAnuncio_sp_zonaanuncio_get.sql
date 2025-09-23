-- Stored Procedure: sp_zonaanuncio_get
-- Tipo: CRUD
-- Descripción: Obtiene la información de zona/subzona/recaudadora para un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-27 19:51:59

CREATE OR REPLACE FUNCTION sp_zonaanuncio_get(p_anuncio INTEGER)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT anuncio, zona, subzona, recaud, feccap, capturista FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;