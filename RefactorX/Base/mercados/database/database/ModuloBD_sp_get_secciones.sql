-- Stored Procedure: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene todas las secciones
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

DROP FUNCTION IF EXISTS sp_get_secciones();

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion char(2), descripcion varchar(30))
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT s.seccion, s.descripcion FROM publico.ta_11_secciones s ORDER BY s.seccion;
END; $$;