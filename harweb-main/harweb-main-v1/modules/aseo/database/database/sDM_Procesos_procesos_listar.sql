-- Stored Procedure: procesos_listar
-- Tipo: Catalog
-- Descripción: Devuelve todos los procesos registrados.
-- Generado para formulario: sDM_Procesos
-- Fecha: 2025-08-27 15:18:06

CREATE OR REPLACE FUNCTION procesos_listar()
RETURNS TABLE(id integer, nombre text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM procesos ORDER BY id;
END;
$$ LANGUAGE plpgsql;