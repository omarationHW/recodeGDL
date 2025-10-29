-- Stored Procedure: sp_listados_get_claves
-- Tipo: Catalog
-- Descripción: Obtiene todas las claves de tipo_clave<>4 para el formulario de Listados.
-- Generado para formulario: Listados
-- Fecha: 2025-08-27 13:56:06

CREATE OR REPLACE FUNCTION sp_listados_get_claves()
RETURNS TABLE(id_clave integer, tipo_clave smallint, concepto_tipo varchar, clave varchar, descrip varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_clave, tipo_clave, concepto_tipo, clave, descrip FROM ta_15_claves WHERE tipo_clave <> 4 ORDER BY tipo_clave, clave;
END;
$$ LANGUAGE plpgsql;