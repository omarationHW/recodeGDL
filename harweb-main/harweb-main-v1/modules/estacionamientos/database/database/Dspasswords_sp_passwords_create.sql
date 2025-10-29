-- Stored Procedure: sp_passwords_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en ta_12_passwords.
-- Generado para formulario: Dspasswords
-- Fecha: 2025-08-27 13:35:26

CREATE OR REPLACE FUNCTION sp_passwords_create(
    p_usuario VARCHAR,
    p_nombre VARCHAR,
    p_estado CHAR(1),
    p_id_rec SMALLINT,
    p_nivel SMALLINT
) RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado CHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ta_12_passwords (usuario, nombre, estado, id_rec, nivel)
    VALUES (p_usuario, p_nombre, p_estado, p_id_rec, p_nivel)
    RETURNING id_usuario INTO new_id;

    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords WHERE id_usuario = new_id;
END;
$$ LANGUAGE plpgsql;