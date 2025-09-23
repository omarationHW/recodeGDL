-- Stored Procedure: sp_elaboro_mntto_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_17_elaboroficio
-- Generado para formulario: ElaboroMntto
-- Fecha: 2025-08-27 14:33:12

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_delete(
    p_id_control integer
) RETURNS integer AS $$
BEGIN
    DELETE FROM ta_17_elaboroficio WHERE id_control = p_id_control;
    RETURN 1;
END;
$$ LANGUAGE plpgsql;