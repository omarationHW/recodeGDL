-- Stored Procedure: sp_catalog_tipos
-- Tipo: Catalog
-- Descripción: Catálogo de tipos de fondo para convenios.
-- Generado para formulario: RptPagosContabilidad
-- Fecha: 2025-08-27 15:44:23

CREATE OR REPLACE FUNCTION sp_catalog_tipos()
RETURNS TABLE (
    tipo SMALLINT,
    descripcion VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;