-- Stored Procedure: sp_elabora_convenios_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de quien elabora convenios.
-- Generado para formulario: ElaboraConvenios
-- Fecha: 2025-08-27 14:29:39

CREATE OR REPLACE FUNCTION sp_elabora_convenios_delete(
    p_id_control INTEGER,
    p_id_usuario INTEGER
) RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM ta_17_elaboroficio WHERE id_control = p_id_control;
    RETURN QUERY SELECT TRUE;
END;
$$ LANGUAGE plpgsql;