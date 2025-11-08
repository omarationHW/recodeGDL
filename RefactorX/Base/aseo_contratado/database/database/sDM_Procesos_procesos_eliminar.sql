-- Stored Procedure: procesos_eliminar
-- Tipo: CRUD
-- Descripción: Elimina un proceso por su ID.
-- Generado para formulario: sDM_Procesos
-- Fecha: 2025-08-27 15:18:06

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