-- Stored Procedure: sp_elaboro_mntto_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro en ta_17_elaboroficio
-- Generado para formulario: ElaboroMntto
-- Fecha: 2025-08-27 14:33:12

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_update(
    p_id_control integer,
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar,
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar
) RETURNS integer AS $$
BEGIN
    UPDATE ta_17_elaboroficio SET
        id_rec = p_id_rec,
        id_usu_titular = p_id_usu_titular,
        iniciales_titular = p_iniciales_titular,
        id_usu_elaboro = p_id_usu_elaboro,
        iniciales_elaboro = p_iniciales_elaboro
    WHERE id_control = p_id_control;
    RETURN 1;
END;
$$ LANGUAGE plpgsql;