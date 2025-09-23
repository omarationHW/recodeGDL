-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SDM_PROCESOS (EXACTO del archivo original)
-- Archivo: 102_SP_ASEO_SDM_PROCESOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SDM_PROCESOS (EXACTO del archivo original)
-- Archivo: 102_SP_ASEO_SDM_PROCESOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SDM_PROCESOS (EXACTO del archivo original)
-- Archivo: 102_SP_ASEO_SDM_PROCESOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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

