-- Stored Procedure: sp_cat_requisitos_search
-- Tipo: Catalog
-- Descripción: Busca requisitos por descripción (LIKE).
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-27 17:05:51

CREATE OR REPLACE FUNCTION sp_cat_requisitos_search(p_descripcion varchar)
RETURNS TABLE(req integer, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM c_girosreq WHERE descripcion ILIKE '%' || p_descripcion || '%' ORDER BY req;
END;
$$ LANGUAGE plpgsql;