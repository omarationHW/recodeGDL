-- Stored Procedure: add_anuncios_to_grupo
-- Tipo: CRUD
-- Descripción: Agrega una lista de anuncios a un grupo.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION add_anuncios_to_grupo(grupo_id INT, anuncios_json TEXT)
RETURNS TABLE(anuncio INT) AS $$
DECLARE
  anuncios INT[];
  i INT;
BEGIN
  SELECT array_agg((value::INT)) INTO anuncios FROM json_array_elements_text(anuncios_json::json);
  IF anuncios IS NOT NULL THEN
    FOREACH i IN ARRAY anuncios LOOP
      INSERT INTO anuncios_detgrupo(anuncios_grupos_id, anuncio)
      VALUES (grupo_id, i)
      ON CONFLICT DO NOTHING;
      RETURN NEXT i;
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;