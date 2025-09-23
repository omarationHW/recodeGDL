-- Stored Procedure: sp_get_catalogo_descuentos
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de tipos de descuentos predial
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_get_catalogo_descuentos()
RETURNS TABLE(cvedescuento INTEGER, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY SELECT cvedescuento, descripcion FROM c_descpred ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;