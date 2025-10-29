-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_deudagrupo
-- Generado: 2025-08-27 15:55:12
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_deudagrupo_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros de la tabla deudagrupo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_deudagrupo_list()
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_deudagrupo_show
-- Tipo: Catalog
-- Descripción: Devuelve un registro específico de deudagrupo por id.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_deudagrupo_show(p_id integer)
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_deudagrupo_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en deudagrupo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_deudagrupo_create(p_nombre varchar, p_descripcion varchar)
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO deudagrupo (nombre, descripcion) VALUES (p_nombre, p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_deudagrupo_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en deudagrupo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_deudagrupo_update(p_id integer, p_nombre varchar, p_descripcion varchar)
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
BEGIN
  UPDATE deudagrupo SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_deudagrupo_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de deudagrupo por id.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_deudagrupo_delete(p_id integer)
RETURNS TABLE(success boolean, message varchar) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM deudagrupo WHERE id = p_id;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false, 'Registro no encontrado';
  ELSE
    DELETE FROM deudagrupo WHERE id = p_id;
    RETURN QUERY SELECT true, 'Registro eliminado correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

