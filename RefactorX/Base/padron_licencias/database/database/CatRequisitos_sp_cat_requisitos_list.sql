-- Stored Procedure: sp_cat_requisitos_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los requisitos del catálogo.
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-27 17:05:51

CREATE OR REPLACE FUNCTION sp_cat_requisitos_list()
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq ORDER BY req;
END;
$$ LANGUAGE plpgsql;