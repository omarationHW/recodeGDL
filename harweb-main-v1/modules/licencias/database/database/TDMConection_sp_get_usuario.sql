-- Stored Procedure: sp_get_usuario
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por nombre de usuario.
-- Generado para formulario: TDMConection
-- Fecha: 2025-08-26 18:15:59

CREATE OR REPLACE FUNCTION sp_get_usuario(p_usuario VARCHAR)
RETURNS TABLE(id INTEGER, usuario VARCHAR, nombres VARCHAR, password VARCHAR, cvedepto INTEGER, cvedependencia INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id, usuario, nombres, password, cvedepto, cvedependencia FROM usuarios WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;