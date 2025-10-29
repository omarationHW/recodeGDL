-- Stored Procedure: sp_catalogo_secciones
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de secciones de mercado.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_catalogo_secciones() RETURNS TABLE(
    seccion text,
    descripcion text
) AS $$
BEGIN
    RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion;
END;
$$ LANGUAGE plpgsql;