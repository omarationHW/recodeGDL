-- Stored Procedure: sp_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos
-- Generado para formulario: CallesMntto
-- Fecha: 2025-08-27 13:59:54

CREATE OR REPLACE FUNCTION sp_get_tipos() RETURNS TABLE(tipo smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;