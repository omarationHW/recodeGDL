-- Stored Procedure: sp_zonaanuncio_create
-- Tipo: CRUD
-- Descripción: Crea un registro de zona para un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-27 19:51:59

CREATE OR REPLACE FUNCTION sp_zonaanuncio_create(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO anuncios_zona (anuncio, zona, subzona, recaud, feccap, capturista)
  VALUES (p_anuncio, p_zona, p_subzona, p_recaud, NOW(), p_capturista);
END; $$;