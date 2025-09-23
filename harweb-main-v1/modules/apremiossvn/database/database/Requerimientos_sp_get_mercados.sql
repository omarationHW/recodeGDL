-- Stored Procedure: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene la lista de mercados disponibles para el usuario.
-- Generado para formulario: Requerimientos
-- Fecha: 2025-08-27 14:28:57

CREATE OR REPLACE FUNCTION sp_get_mercados(p_user_id INT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_mercado, descripcion FROM mercados WHERE user_id = p_user_id OR p_user_id = 1;
END;
$$ LANGUAGE plpgsql;