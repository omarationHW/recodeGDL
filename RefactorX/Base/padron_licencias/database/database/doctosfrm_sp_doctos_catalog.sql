-- Stored Procedure: sp_doctos_catalog
-- Tipo: Catalog
-- Descripción: Catálogo de documentos posibles (para checkboxes)
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-26 16:10:05

CREATE OR REPLACE FUNCTION sp_doctos_catalog() RETURNS TABLE(id INTEGER, nombre TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre FROM doctos_catalogo WHERE vigente = TRUE ORDER BY id;
END;
$$ LANGUAGE plpgsql;