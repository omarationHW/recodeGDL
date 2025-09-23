-- Stored Procedure: sp_deudagrupo_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros de la tabla deudagrupo.
-- Generado para formulario: sfrm_deudagrupo
-- Fecha: 2025-08-27 15:55:12

CREATE OR REPLACE FUNCTION sp_deudagrupo_list()
RETURNS TABLE(id integer, nombre varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT id, nombre, descripcion FROM deudagrupo ORDER BY id;
END;
$$ LANGUAGE plpgsql;