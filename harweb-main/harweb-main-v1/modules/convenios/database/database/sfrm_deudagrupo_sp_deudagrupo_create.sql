-- Stored Procedure: sp_deudagrupo_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro en deudagrupo.
-- Generado para formulario: sfrm_deudagrupo
-- Fecha: 2025-08-27 15:55:12

CREATE OR REPLACE FUNCTION sp_deudagrupo_create(p_nombre varchar, p_descripcion varchar)
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
DECLARE
  new_id integer;
BEGIN
  INSERT INTO deudagrupo (nombre, descripcion) VALUES (p_nombre, p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;