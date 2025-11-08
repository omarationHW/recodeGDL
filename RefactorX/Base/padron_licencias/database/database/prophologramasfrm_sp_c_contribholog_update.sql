-- Stored Procedure: sp_c_contribholog_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en c_contribholog y devuelve el registro actualizado.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-26 17:31:13

CREATE OR REPLACE FUNCTION sp_c_contribholog_update(
    p_idcontrib integer,
    p_nombre varchar,
    p_domicilio varchar,
    p_colonia varchar,
    p_telefono varchar,
    p_rfc varchar,
    p_curp varchar,
    p_email varchar,
    p_capturista varchar
)
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
    UPDATE c_contribholog SET
        nombre = upper(p_nombre),
        domicilio = upper(p_domicilio),
        colonia = upper(p_colonia),
        telefono = upper(p_telefono),
        rfc = upper(p_rfc),
        curp = upper(p_curp),
        email = p_email,
        capturista = upper(p_capturista)
    WHERE idcontrib = p_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;