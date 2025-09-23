-- Stored Procedure: sp_elabora_convenios_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de quien elabora convenios.
-- Generado para formulario: ElaboraConvenios
-- Fecha: 2025-08-27 14:29:39

CREATE OR REPLACE FUNCTION sp_elabora_convenios_create(
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
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ta_17_elaboroficio (id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro)
    VALUES (p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro)
    RETURNING id_control INTO new_id;
    RETURN QUERY SELECT id_control, id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    FROM ta_17_elaboroficio WHERE id_control = new_id;
END;
$$ LANGUAGE plpgsql;