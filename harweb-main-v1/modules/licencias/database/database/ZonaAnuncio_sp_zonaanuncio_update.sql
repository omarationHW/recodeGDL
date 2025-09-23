-- Stored Procedure: sp_zonaanuncio_update
-- Tipo: CRUD
-- Descripción: Actualiza la zona/subzona/recaudadora de un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-27 19:51:59

CREATE OR REPLACE FUNCTION sp_zonaanuncio_update(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE anuncios_zona SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW(), capturista = p_capturista
  WHERE anuncio = p_anuncio;
END; $$;