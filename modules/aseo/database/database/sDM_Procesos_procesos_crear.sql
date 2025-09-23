-- Stored Procedure: procesos_crear
-- Tipo: CRUD
-- Descripción: Crea un nuevo proceso.
-- Generado para formulario: sDM_Procesos
-- Fecha: 2025-08-27 15:18:06

CREATE OR REPLACE FUNCTION procesos_crear(p_nombre text, p_descripcion text)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO procesos(nombre, descripcion) VALUES (p_nombre, p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;