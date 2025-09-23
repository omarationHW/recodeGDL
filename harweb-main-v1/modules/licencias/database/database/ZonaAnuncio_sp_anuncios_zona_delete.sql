-- Stored Procedure: sp_anuncios_zona_delete
-- Tipo: CRUD
-- Descripción: Elimina el registro de zona para un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-26 18:26:24

CREATE OR REPLACE FUNCTION sp_anuncios_zona_delete(p_anuncio INTEGER)
RETURNS VOID AS $$
BEGIN
  DELETE FROM anuncios_zona WHERE anuncio = p_anuncio;
END;
$$ LANGUAGE plpgsql;