-- Stored Procedure: sp_get_catalog
-- Tipo: Catalog
-- Descripción: Obtiene catálogos varios (ejemplo: infracciones, usuarios, etc).
-- Generado para formulario: Acceso
-- Fecha: 2025-08-27 13:19:38

CREATE OR REPLACE FUNCTION sp_get_catalog(p_catalog TEXT)
RETURNS SETOF RECORD AS $$
DECLARE
  sql TEXT;
BEGIN
  IF p_catalog = 'infracciones' THEN
    RETURN QUERY EXECUTE 'SELECT num_clave, descripcion FROM ta14_infraccion ORDER BY num_clave';
  ELSIF p_catalog = 'usuarios' THEN
    RETURN QUERY EXECUTE 'SELECT id_usuario, usuario, nombre, nivel FROM usuarios WHERE estado = ''A'' ORDER BY usuario';
  ELSE
    RAISE EXCEPTION 'Catálogo no soportado';
  END IF;
END;
$$ LANGUAGE plpgsql;