-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Dspasswords
-- Generado: 2025-08-27 13:35:26
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_passwords_list
-- Tipo: Catalog
-- Descripción: Lista los registros de ta_12_passwords filtrando por usuario (si se provee).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_passwords_list(p_usuario VARCHAR)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado CHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords
    WHERE (p_usuario IS NULL OR usuario = p_usuario);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_passwords_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en ta_12_passwords.
-- --------------------------------------------

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

-- ============================================

-- SP 3/4: sp_passwords_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en ta_12_passwords.
-- --------------------------------------------

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

-- ============================================

-- SP 4/4: sp_passwords_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_12_passwords por id_usuario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_passwords_delete(
    p_id_usuario INTEGER
) RETURNS TABLE (
    deleted BOOLEAN
) AS $$
BEGIN
    DELETE FROM ta_12_passwords WHERE id_usuario = p_id_usuario;
    RETURN QUERY SELECT TRUE AS deleted;
END;
$$ LANGUAGE plpgsql;

-- ============================================

