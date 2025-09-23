-- Stored Procedure: procesos_actualizar
-- Tipo: CRUD
-- Descripción: Actualiza un proceso existente.
-- Generado para formulario: sDM_Procesos
-- Fecha: 2025-08-27 15:18:06

CREATE OR REPLACE FUNCTION procesos_actualizar(p_id integer, p_nombre text, p_descripcion text)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
BEGIN
  UPDATE procesos SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;