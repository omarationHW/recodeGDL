-- Stored Procedure: sp_get_giro
-- Tipo: Catalog
-- Descripción: Obtiene la información de un giro comercial.
-- Generado para formulario: repestado
-- Fecha: 2025-08-26 17:55:36

CREATE OR REPLACE FUNCTION sp_get_giro(p_id_giro INTEGER)
RETURNS TABLE (
  id_giro INTEGER,
  descripcion VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_giro, descripcion
  FROM c_giros
  WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;