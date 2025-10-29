-- Stored Procedure: sp_consdesc_instituciones
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de instituciones
-- Generado para formulario: consdesc
-- Fecha: 2025-08-26 23:20:34

CREATE OR REPLACE FUNCTION sp_consdesc_instituciones()
RETURNS TABLE (
    cveinst INTEGER,
    institucion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveinst, institucion FROM c_instituciones ORDER BY institucion;
END;
$$ LANGUAGE plpgsql;