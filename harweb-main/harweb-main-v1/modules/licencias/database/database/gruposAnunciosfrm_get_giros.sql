-- Stored Procedure: get_giros
-- Tipo: Catalog
-- Descripción: Obtiene los giros activos (tipo = 'A').
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION get_giros()
RETURNS TABLE(id_giro INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_giro, descripcion FROM c_giros WHERE tipo = 'A' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;