-- Stored Procedure: sp_catalogo_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones
-- Generado para formulario: EnergiaModif
-- Fecha: 2025-08-26 23:56:17

CREATE OR REPLACE FUNCTION sp_catalogo_secciones() RETURNS TABLE (
    seccion varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END;
$$ LANGUAGE plpgsql;