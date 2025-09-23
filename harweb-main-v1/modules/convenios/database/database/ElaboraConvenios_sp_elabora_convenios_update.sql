-- Stored Procedure: sp_elabora_convenios_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente de quien elabora convenios.
-- Generado para formulario: ElaboraConvenios
-- Fecha: 2025-08-27 14:29:39

CREATE OR REPLACE FUNCTION sp_elabora_convenios_update(
    p_id_control INTEGER,
    p_id_rec INTEGER,
    p_id_usu_titular INTEGER,
    p_iniciales_titular VARCHAR(10),
    p_id_usu_elaboro INTEGER,
    p_iniciales_elaboro VARCHAR(10),
    p_id_usuario INTEGER
) RETURNS TABLE (
    id_control INTEGER,
    id_rec INTEGER,
    id_usu_titular INTEGER,
    iniciales_titular VARCHAR(10),
    id_usu_elaboro INTEGER,
    iniciales_elaboro VARCHAR(10)
) AS $$
BEGIN
    UPDATE ta_17_elaboroficio
    SET id_rec = p_id_rec,
        id_usu_titular = p_id_usu_titular,
        iniciales_titular = p_iniciales_titular,
        id_usu_elaboro = p_id_usu_elaboro,
        iniciales_elaboro = p_iniciales_elaboro
    WHERE id_control = p_id_control;
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM ta_17_elaboroficio WHERE id_control = p_id_control;
END;
$$ LANGUAGE plpgsql;