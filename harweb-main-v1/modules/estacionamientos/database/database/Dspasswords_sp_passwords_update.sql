-- Stored Procedure: sp_passwords_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en ta_12_passwords.
-- Generado para formulario: Dspasswords
-- Fecha: 2025-08-27 13:35:26

CREATE OR REPLACE FUNCTION sp_passwords_update(
    p_id_usuario INTEGER,
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
BEGIN
    UPDATE ta_12_passwords
    SET usuario = p_usuario,
        nombre = p_nombre,
        estado = p_estado,
        id_rec = p_id_rec,
        nivel = p_nivel
    WHERE id_usuario = p_id_usuario;

    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;