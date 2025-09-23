-- Stored Procedure: procesos_obtener
-- Tipo: Catalog
-- Descripción: Obtiene un proceso por su ID.
-- Generado para formulario: sDM_Procesos
-- Fecha: 2025-08-27 15:18:06

CREATE OR REPLACE FUNCTION procesos_obtener(p_id integer)
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;