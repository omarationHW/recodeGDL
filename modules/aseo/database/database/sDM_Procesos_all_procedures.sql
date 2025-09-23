-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sDM_Procesos
-- Generado: 2025-08-27 15:18:06
-- Total SPs: 5
-- ============================================

-- SP 1/5: procesos_listar
-- Tipo: Catalog
-- Descripción: Devuelve todos los procesos registrados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION procesos_listar()
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos ORDER BY id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: procesos_obtener
-- Tipo: Catalog
-- Descripción: Obtiene un proceso por su ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION procesos_obtener(p_id integer)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: procesos_crear
-- Tipo: CRUD
-- Descripción: Crea un nuevo proceso.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION procesos_crear(p_nombre text, p_descripcion text)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO procesos(nombre, descripcion) VALUES (p_nombre, p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: procesos_actualizar
-- Tipo: CRUD
-- Descripción: Actualiza un proceso existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION procesos_actualizar(p_id integer, p_nombre text, p_descripcion text)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
BEGIN
  UPDATE procesos SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: procesos_eliminar
-- Tipo: CRUD
-- Descripción: Elimina un proceso por su ID.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION procesos_eliminar(p_id integer)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
DECLARE
  deleted_row RECORD;
BEGIN
  SELECT * INTO deleted_row FROM procesos WHERE id = p_id;
  DELETE FROM procesos WHERE id = p_id;
  RETURN QUERY SELECT deleted_row.id, deleted_row.nombre, deleted_row.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

