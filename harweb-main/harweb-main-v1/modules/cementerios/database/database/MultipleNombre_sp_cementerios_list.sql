-- Stored Procedure: sp_cementerios_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de cementerios
-- Generado para formulario: MultipleNombre
-- Fecha: 2025-08-27 14:42:42

CREATE OR REPLACE FUNCTION sp_cementerios_list()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, nombre FROM tc_13_cementerios ORDER BY cementerio;
END;
$$ LANGUAGE plpgsql;