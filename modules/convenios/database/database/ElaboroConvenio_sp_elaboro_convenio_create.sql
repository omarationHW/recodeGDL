-- Stored Procedure: sp_elaboro_convenio_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de quien elaboró convenio.
-- Generado para formulario: ElaboroConvenio
-- Fecha: 2025-08-27 14:31:25

CREATE OR REPLACE FUNCTION sp_elaboro_convenio_create(
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
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_17_elaboroficio (id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro)
    VALUES (p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro)
    RETURNING id_control INTO new_id;
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM ta_17_elaboroficio WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;