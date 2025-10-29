-- Stored Procedure: sp_elaboro_mntto_create
-- Tipo: CRUD
-- Descripción: Crea un registro en ta_17_elaboroficio
-- Generado para formulario: ElaboroMntto
-- Fecha: 2025-08-27 14:33:12

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_create(
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar,
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_17_elaboroficio (
        id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    ) VALUES (
        p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro
    ) RETURNING id_control INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;