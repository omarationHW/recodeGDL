-- Stored Procedure: sp_catrequisitos_list
-- Tipo: Catalog
-- Descripción: Obtiene todos los requisitos del catálogo
-- Generado para formulario: CatRequisitos
-- Fecha: 2025-08-26 15:26:45

CREATE OR REPLACE FUNCTION sp_catrequisitos_list()
RETURNS TABLE(req integer, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT req, descripcion FROM cat_requisitos ORDER BY req;
END;
$$ LANGUAGE plpgsql;