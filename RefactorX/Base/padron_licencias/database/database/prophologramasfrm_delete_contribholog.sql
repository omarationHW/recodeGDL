-- Stored Procedure: delete_contribholog
-- Tipo: CRUD
-- Descripción: Elimina un propietario de holograma por idcontrib y retorna el registro eliminado.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-27 18:56:37

CREATE OR REPLACE FUNCTION delete_contribholog(p_idcontrib integer)
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
DECLARE
    v_row RECORD;
BEGIN
    SELECT * INTO v_row FROM c_contribholog WHERE idcontrib = p_idcontrib;
    IF FOUND THEN
        DELETE FROM c_contribholog WHERE idcontrib = p_idcontrib;
        RETURN QUERY SELECT v_row.*;
    END IF;
END;
$$ LANGUAGE plpgsql;