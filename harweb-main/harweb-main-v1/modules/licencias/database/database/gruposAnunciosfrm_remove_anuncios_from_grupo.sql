-- Stored Procedure: remove_anuncios_from_grupo
-- Tipo: CRUD
-- Descripción: Elimina una lista de anuncios de un grupo.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION remove_anuncios_from_grupo(grupo_id INT, anuncios_json TEXT)
RETURNS TABLE(anuncio INT) AS $$
DECLARE
  anuncios INT[];
  i INT;
BEGIN
  SELECT array_agg((value::INT)) INTO anuncios FROM json_array_elements_text(anuncios_json::json);
  IF anuncios IS NOT NULL THEN
    FOREACH i IN ARRAY anuncios LOOP
      DELETE FROM anuncios_detgrupo WHERE anuncios_grupos_id = grupo_id AND anuncio = i;
      RETURN NEXT i;
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;