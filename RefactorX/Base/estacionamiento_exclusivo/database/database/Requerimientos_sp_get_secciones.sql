-- Stored Procedure: sp_get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene la lista de secciones de mercados.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_get_secciones()
RETURNS TABLE(seccion TEXT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM secciones;
END;
$$ LANGUAGE plpgsql;