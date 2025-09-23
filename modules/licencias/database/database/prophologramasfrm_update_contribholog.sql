-- Stored Procedure: update_contribholog
-- Tipo: CRUD
-- Descripción: Actualiza un propietario de holograma existente y retorna el registro actualizado.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-27 18:56:37

CREATE OR REPLACE FUNCTION update_contribholog(
    p_idcontrib integer,
    p_nombre varchar,
    p_domicilio varchar,
    p_colonia varchar,
    p_telefono varchar,
    p_rfc varchar,
    p_curp varchar,
    p_email varchar,
    p_capturista varchar
) RETURNS TABLE (
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
    UPDATE c_contribholog
    SET nombre = p_nombre,
        domicilio = p_domicilio,
        colonia = p_colonia,
        telefono = p_telefono,
        rfc = p_rfc,
        curp = p_curp,
        email = p_email,
        capturista = p_capturista
    WHERE idcontrib = p_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = p_idcontrib;
END;
$$ LANGUAGE plpgsql;