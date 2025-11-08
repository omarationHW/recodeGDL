-- Stored Procedure: get_contribholog_by_id
-- Tipo: Catalog
-- Descripción: Obtiene un propietario de holograma por su idcontrib.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-27 18:56:37

CREATE OR REPLACE FUNCTION get_contribholog_by_id(p_idcontrib integer)
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
    WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;