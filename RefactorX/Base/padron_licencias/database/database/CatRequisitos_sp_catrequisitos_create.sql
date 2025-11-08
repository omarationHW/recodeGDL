-- Stored Procedure: sp_catrequisitos_create
-- Tipo: CRUD
-- Descripción: Agrega un nuevo requisito al catálogo
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-26 15:26:45

CREATE OR REPLACE FUNCTION sp_catrequisitos_create(p_descripcion text)
RETURNS TABLE(req integer, descripcion text) AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO cat_requisitos(descripcion) VALUES (p_descripcion) RETURNING req INTO new_id;
  RETURN QUERY SELECT req, descripcion FROM cat_requisitos WHERE req = new_id;
END;
$$ LANGUAGE plpgsql;