-- Stored Procedure: sp_consultar_sanandres_paginated
-- Tipo: Catalog
-- Descripción: Devuelve registros paginados de la tabla 'datos' del cementerio San Andrés.
-- Generado para formulario: ConsultaSAndres
-- Fecha: 2025-08-27 14:24:28

CREATE OR REPLACE FUNCTION sp_consultar_sanandres_paginated(p_page integer, p_per_page integer)
RETURNS TABLE (
    id integer,
    clase text,
    seccion text,
    linea text,
    fosa text,
    ppago text,
    nombre text,
    fcompra timestamp,
    otros text,
    clave smallint,
    medida float,
    calle text,
    colonia text
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, clase, seccion, linea, fosa, ppago, nombre, fcompra, otros, clave, medida, calle, colonia
    FROM datos
    ORDER BY id
    OFFSET ((p_page - 1) * p_per_page)
    LIMIT p_per_page;
END;
$$ LANGUAGE plpgsql;