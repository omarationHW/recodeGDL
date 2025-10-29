-- Stored Procedure: sp_cat_requisitos_create
-- Tipo: CRUD
-- Descripción: Agrega un nuevo requisito al catálogo.
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-27 17:05:51

CREATE OR REPLACE FUNCTION sp_cat_requisitos_create(p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
DECLARE
  new_req integer;
BEGIN
  SELECT COALESCE(MAX(req),0)+1 INTO new_req FROM c_girosreq;
  INSERT INTO c_girosreq(req, descripcion) VALUES (new_req, p_descripcion);
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE req = new_req;
END;
$$ LANGUAGE plpgsql;