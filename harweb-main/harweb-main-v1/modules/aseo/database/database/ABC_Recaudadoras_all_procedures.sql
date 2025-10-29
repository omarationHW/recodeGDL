-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Recaudadoras
-- Generado: 2025-08-27 13:27:06
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_insert_recaudadora
-- Tipo: CRUD
-- Descripción: Inserta una nueva recaudadora si no existe el número.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una recaudadora con ese número.';
    ELSE
        INSERT INTO ta_16_recaudadoras(num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
        RETURN QUERY SELECT TRUE, 'Recaudadora agregada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_update_recaudadora
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una recaudadora existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'No existe la recaudadora.';
    ELSE
        UPDATE ta_16_recaudadoras SET descripcion = p_descripcion WHERE num_rec = p_num_rec;
        RETURN QUERY SELECT TRUE, 'Recaudadora actualizada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_delete_recaudadora
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_recaudadora(p_num_rec SMALLINT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM ta_16_contratos WHERE id_rec = p_num_rec;
    IF v_count > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.';
    END IF;
    DELETE FROM ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Recaudadora eliminada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'No existe la recaudadora.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

