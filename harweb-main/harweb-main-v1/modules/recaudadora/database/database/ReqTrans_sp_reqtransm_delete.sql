-- Stored Procedure: sp_reqtransm_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de requerimiento de transmisión patrimonial
-- Generado para formulario: ReqTrans
-- Fecha: 2025-08-27 15:05:46

CREATE OR REPLACE FUNCTION sp_reqtransm_delete(p_id integer) RETURNS boolean AS $$
BEGIN
    DELETE FROM reqtransm WHERE id = p_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;