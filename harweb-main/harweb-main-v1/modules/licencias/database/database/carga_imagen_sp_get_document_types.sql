-- Stored Procedure: sp_get_document_types
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de documentos disponibles
-- Generado para formulario: carga_imagen
-- Fecha: 2025-08-27 16:41:18

CREATE OR REPLACE FUNCTION sp_get_document_types()
RETURNS TABLE(id integer, documento varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, documento FROM c_doctos ORDER BY documento;
END;
$$ LANGUAGE plpgsql;