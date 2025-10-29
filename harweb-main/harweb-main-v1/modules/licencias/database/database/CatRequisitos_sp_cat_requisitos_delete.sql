-- Stored Procedure: sp_cat_requisitos_delete
-- Tipo: CRUD
-- Descripción: Elimina un requisito del catálogo.
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-27 17:05:51

CREATE OR REPLACE FUNCTION sp_cat_requisitos_delete(p_req integer)
RETURNS TABLE(req integer, descripcion varchar) AS $$
DECLARE
  old_desc varchar;
BEGIN
  SELECT descripcion INTO old_desc FROM c_girosreq WHERE req = p_req;
  DELETE FROM c_girosreq WHERE req = p_req;
  RETURN QUERY SELECT p_req, old_desc;
END;
$$ LANGUAGE plpgsql;