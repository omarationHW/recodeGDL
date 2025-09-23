-- Stored Procedure: sp_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene todos los registros del catálogo de tipos
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:53:53

CREATE OR REPLACE FUNCTION sp_get_tipos()
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;