-- Stored Procedure: sp_anuncios_zona_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de zona para un anuncio
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-26 18:26:24

CREATE OR REPLACE FUNCTION sp_anuncios_zona_create(p_anuncio INTEGER, p_zona SMALLINT, p_subzona SMALLINT, p_recaud SMALLINT, p_capturista VARCHAR)
RETURNS VOID AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM anuncios_zona WHERE anuncio = p_anuncio) THEN
    RAISE EXCEPTION 'Ya existe registro para este anuncio';
  END IF;
  INSERT INTO anuncios_zona (anuncio, zona, subzona, recaud, feccap, capturista)
  VALUES (p_anuncio, p_zona, p_subzona, p_recaud, NOW(), p_capturista);
END;
$$ LANGUAGE plpgsql;