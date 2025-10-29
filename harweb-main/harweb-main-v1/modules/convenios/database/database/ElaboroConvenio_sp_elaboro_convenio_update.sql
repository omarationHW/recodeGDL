-- Stored Procedure: sp_elaboro_convenio_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente de quien elaboró convenio.
-- Generado para formulario: ElaboroConvenio
-- Fecha: 2025-08-27 14:31:25

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_update(
    p_id_control integer,
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar(10),
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar(10)
) RETURNS TABLE (
    id_control integer,
    id_rec integer,
    id_usu_titular integer,
    iniciales_titular varchar(10),
    id_usu_elaboro integer,
    iniciales_elaboro varchar(10)
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