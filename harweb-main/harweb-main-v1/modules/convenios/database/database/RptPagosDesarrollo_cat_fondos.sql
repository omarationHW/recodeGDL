-- Stored Procedure: cat_fondos
-- Tipo: Catalog
-- Descripción: Catálogo de fondos (tipos de obra pública) para combos.
-- Generado para formulario: RptPagosDesarrollo
-- Fecha: 2025-08-27 15:46:39

CREATE OR REPLACE FUNCTION cat_fondos()
RETURNS TABLE (
    tipo SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;