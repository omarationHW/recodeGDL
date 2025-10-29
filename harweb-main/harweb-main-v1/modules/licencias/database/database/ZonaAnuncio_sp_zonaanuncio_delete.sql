-- Stored Procedure: sp_zonaanuncio_delete
-- Tipo: CRUD
-- Descripción: Elimina el registro de zona de un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-27 19:51:59

CREATE OR REPLACE FUNCTION sp_zonaanuncio_delete(p_anuncio INTEGER)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  DELETE FROM anuncios_zona WHERE anuncio = p_anuncio;
END; $$;