-- Stored Procedure: sp_c_contribholog_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de c_contribholog y devuelve el id eliminado.
-- Generado para formulario: prophologramasfrm
-- Fecha: 2025-08-26 17:31:13

CREATE OR REPLACE FUNCTION sp_c_contribholog_delete(p_idcontrib integer)
RETURNS TABLE (idcontrib integer) AS $$
DECLARE
    v_id integer;
BEGIN
    DELETE FROM c_contribholog WHERE idcontrib = p_idcontrib RETURNING idcontrib INTO v_id;
    RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;