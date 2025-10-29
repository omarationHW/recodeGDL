-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ColoniasMntto
-- Generado: 2025-08-27 14:07:19
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_colonias_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva colonia en ta_17_colonias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_colonias_create(
    p_colonia integer,
    p_descripcion varchar,
    p_id_rec integer,
    p_id_zona integer,
    p_col_obra94 integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'La colonia ya existe';
        RETURN;
    END IF;
    INSERT INTO ta_17_colonias (colonia, descripcion, id_rec, id_zona, col_obra94, id_usuario, fecha_actual)
    VALUES (p_colonia, p_descripcion, p_id_rec, p_id_zona, p_col_obra94, p_id_usuario, CURRENT_TIMESTAMP);
    RETURN QUERY SELECT true, 'Colonia insertada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_colonias_update
-- Tipo: CRUD
-- Descripción: Actualiza una colonia existente en ta_17_colonias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_colonias_update(
    p_colonia integer,
    p_descripcion varchar,
    p_id_rec integer,
    p_id_zona integer,
    p_col_obra94 integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'La colonia no existe';
        RETURN;
    END IF;
    UPDATE ta_17_colonias
    SET descripcion = p_descripcion,
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        col_obra94 = p_col_obra94,
        id_usuario = p_id_usuario,
        fecha_actual = CURRENT_TIMESTAMP
    WHERE colonia = p_colonia;
    RETURN QUERY SELECT true, 'Colonia actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_colonias_delete
-- Tipo: CRUD
-- Descripción: Elimina una colonia de ta_17_colonias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_colonias_delete(
    p_colonia integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'La colonia no existe';
        RETURN;
    END IF;
    DELETE FROM ta_17_colonias WHERE colonia = p_colonia;
    RETURN QUERY SELECT true, 'Colonia eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

