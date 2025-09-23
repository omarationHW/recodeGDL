-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Tipos
-- Generado: 2025-08-27 16:02:02
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_add_tipo
-- Tipo: CRUD
-- Descripción: Agrega un nuevo tipo de convenio a la tabla ta_17_tipos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_tipo(p_tipo integer, p_descripcion varchar)
RETURNS boolean AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_17_tipos WHERE tipo = p_tipo) THEN
        RETURN FALSE;
    END IF;
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (p_tipo, p_descripcion);
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_update_tipo
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo de convenio existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo integer, p_descripcion varchar)
RETURNS boolean AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_delete_tipo
-- Tipo: CRUD
-- Descripción: Elimina un tipo de convenio por su clave.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo integer)
RETURNS boolean AS $$
BEGIN
    DELETE FROM ta_17_tipos WHERE tipo = p_tipo;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

