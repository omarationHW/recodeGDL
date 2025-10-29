-- Stored Procedure: sp_deudagrupo_show
-- Tipo: Catalog
-- Descripción: Devuelve un registro específico de deudagrupo por id.
-- Generado para formulario: sfrm_deudagrupo
-- Fecha: 2025-08-27 15:55:12

CREATE OR REPLACE FUNCTION sp_deudagrupo_show(p_id integer)
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;