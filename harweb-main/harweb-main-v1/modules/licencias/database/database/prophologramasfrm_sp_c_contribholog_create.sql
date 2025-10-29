-- Stored Procedure: sp_c_contribholog_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro en c_contribholog y devuelve el registro insertado.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-26 17:31:13

CREATE OR REPLACE FUNCTION sp_c_contribholog_create(
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
DECLARE
    v_idcontrib integer;
BEGIN
    INSERT INTO c_contribholog (
        nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    ) VALUES (
        upper(p_nombre), upper(p_domicilio), upper(p_colonia), upper(p_telefono), upper(p_rfc), upper(p_curp), p_email, CURRENT_DATE, upper(p_capturista)
    ) RETURNING idcontrib INTO v_idcontrib;

    RETURN QUERY
    SELECT idcontrib, nombre, domicilio, colonia, telefono, rfc, curp, email, feccap, capturista
    FROM c_contribholog WHERE idcontrib = v_idcontrib;
END;
$$ LANGUAGE plpgsql;