-- Stored Procedure: sp_catalog_aplicaciones
-- Tipo: Catalog
-- Descripción: Catálogo de aplicaciones (modulos) disponibles para el formulario.
-- Generado para formulario: Individual_Folio
-- Fecha: 2025-08-27 13:54:03

CREATE OR REPLACE FUNCTION sp_catalog_aplicaciones()
RETURNS TABLE (id integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY VALUES
        (11, 'Mercados'),
        (16, 'Aseo'),
        (24, 'Estacionamientos Publicos'),
        (28, 'Estacionamientos Exclusivos'),
        (14, 'Estacionometros'),
        (13, 'Cementerios');
END;
$$ LANGUAGE plpgsql;