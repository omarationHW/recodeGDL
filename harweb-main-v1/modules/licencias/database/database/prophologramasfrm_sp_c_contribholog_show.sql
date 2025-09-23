-- Stored Procedure: sp_c_contribholog_show
-- Tipo: Catalog
-- Descripción: Devuelve un registro específico de c_contribholog por idcontrib.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-26 17:31:13

CREATE OR REPLACE FUNCTION sp_c_contribholog_show(p_idcontrib integer)
RETURNS TABLE (
    idcontrib integer,
    nombre varchar,
    domicilio varchar,
    colonia varchar,
    telefono varchar,
    rfc varchar,
    curp varchar,
    email varchar,
    feccap date,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog
    WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;