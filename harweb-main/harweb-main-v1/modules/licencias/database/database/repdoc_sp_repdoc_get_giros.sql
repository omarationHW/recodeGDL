-- Stored Procedure: sp_repdoc_get_giros
-- Tipo: Catalog
-- Descripción: Obtiene todos los giros vigentes de un tipo
-- Generado para formulario: repdoc
-- Fecha: 2025-08-27 19:18:22

CREATE OR REPLACE FUNCTION sp_repdoc_get_giros(p_tipo TEXT)
RETURNS TABLE(id_giro INTEGER, descripcion TEXT, clasificacion TEXT, tipo TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo
    FROM c_giros
    WHERE tipo = p_tipo AND vigente = 'V'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;