-- Stored Procedure: get_contribholog_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista completa de propietarios de hologramas ordenados por nombre.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-27 18:56:37

CREATE OR REPLACE FUNCTION get_contribholog_list()
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap timestamp,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog
    ORDER BY nombre;
END;
$$ LANGUAGE plpgsql;