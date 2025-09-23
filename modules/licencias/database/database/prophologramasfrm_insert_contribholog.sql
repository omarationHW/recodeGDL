-- Stored Procedure: insert_contribholog
-- Tipo: CRUD
-- Descripción: Inserta un nuevo propietario de holograma y retorna el registro insertado.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-27 18:56:37

CREATE OR REPLACE FUNCTION insert_contribholog(
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
DECLARE
    v_idcontrib integer;
BEGIN
    INSERT INTO c_contribholog (nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista)
    VALUES (p_nombre, p_domicilio, p_colonia, p_telefono, p_rfc, p_curp, p_email, NOW(), p_capturista)
    RETURNING idcontrib INTO v_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;