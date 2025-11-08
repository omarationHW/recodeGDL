-- Stored Procedure: sp_catrequisitos_search
-- Tipo: Catalog
-- Descripción: Busca requisitos por descripción (case-insensitive)
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-26 15:26:45

CREATE OR REPLACE FUNCTION sp_catrequisitos_search(p_descripcion text)
RETURNS TABLE(req integer, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM cat_requisitos WHERE descripcion ILIKE '%' || p_descripcion || '%' ORDER BY req;
END;
$$ LANGUAGE plpgsql;