-- Stored Procedure: sp_anuncios_zona_update
-- Tipo: CRUD
-- Descripción: Actualiza el registro de zona para un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-26 18:26:24

CREATE OR REPLACE FUNCTION sp_anuncios_zona_update(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID AS $$
BEGIN
  UPDATE anuncios_zona SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW(), capturista = p_capturista
  WHERE anuncio = p_anuncio;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No se encontró el registro para actualizar';
  END IF;
END;
$$ LANGUAGE plpgsql;