-- Stored Procedure: sp_get_dependencia
-- Tipo: Catalog
-- Descripción: Obtiene la información de una dependencia.
-- Generado para formulario: repestado
-- Fecha: 2025-08-26 17:55:36

CREATE OR REPLACE FUNCTION sp_get_dependencia(p_id_dependencia INTEGER)
RETURNS TABLE (
  id_dependencia INTEGER,
  descripcion VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_dependencia, descripcion
  FROM c_dependencias
  WHERE id_dependencia = p_id_dependencia;
END;
$$ LANGUAGE plpgsql;