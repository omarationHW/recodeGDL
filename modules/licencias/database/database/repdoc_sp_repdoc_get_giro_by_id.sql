-- Stored Procedure: sp_repdoc_get_giro_by_id
-- Tipo: Catalog
-- Descripción: Obtiene la información de un giro por su ID
-- Generado para formulario: repdoc
-- Fecha: 2025-08-27 19:18:22

CREATE OR REPLACE FUNCTION sp_repdoc_get_giro_by_id(p_id_giro INTEGER)
RETURNS TABLE(id_giro INTEGER, descripcion TEXT, clasificacion TEXT, tipo TEXT, caracteristicas TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo, caracteristicas
    FROM c_giros
    WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;