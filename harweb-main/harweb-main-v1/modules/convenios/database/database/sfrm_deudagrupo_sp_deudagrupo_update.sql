-- Stored Procedure: sp_deudagrupo_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro existente en deudagrupo.
-- Generado para formulario: sfrm_deudagrupo
-- Fecha: 2025-08-27 15:55:12

CREATE OR REPLACE FUNCTION sp_deudagrupo_update(p_id integer, p_nombre varchar, p_descripcion varchar)
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
BEGIN
  UPDATE deudagrupo SET nombre = p_nombre, descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;