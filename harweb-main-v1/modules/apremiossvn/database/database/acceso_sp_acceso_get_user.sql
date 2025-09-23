-- Stored Procedure: sp_acceso_get_user
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por nombre de usuario.
-- Generado para formulario: acceso
-- Fecha: 2025-08-27 13:30:49

CREATE OR REPLACE FUNCTION sp_acceso_get_user(p_usuario TEXT)
RETURNS TABLE(id_usuario INTEGER, usuario TEXT, nombre TEXT, nivel INTEGER, id_rec INTEGER, id_zona INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT id_usuario, usuario, nombre, nivel, id_rec, id_zona FROM usuarios WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;