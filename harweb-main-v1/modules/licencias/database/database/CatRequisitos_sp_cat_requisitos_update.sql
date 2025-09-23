-- Stored Procedure: sp_cat_requisitos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un requisito.
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-27 17:05:51

CREATE OR REPLACE FUNCTION sp_cat_requisitos_update(p_req integer, p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  UPDATE c_girosreq SET descripcion = p_descripcion WHERE req = p_req;
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE req = p_req;
END;
$$ LANGUAGE plpgsql;