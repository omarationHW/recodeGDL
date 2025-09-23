-- Stored Procedure: sp_anuncios_zona_get
-- Tipo: Catalog
-- Descripción: Obtiene el último registro de zona para un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-26 18:26:24

CREATE OR REPLACE FUNCTION sp_anuncios_zona_get(p_anuncio INTEGER)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT anuncio, zona, subzona, recaud, feccap, capturista FROM anuncios_zona WHERE anuncio = p_anuncio ORDER BY feccap DESC LIMIT 1;
END;
$$ LANGUAGE plpgsql;