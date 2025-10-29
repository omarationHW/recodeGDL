-- Stored Procedure: sp_get_usuarios
-- Tipo: Catalog
-- Descripción: Obtiene los usuarios activos
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_get_usuarios()
RETURNS TABLE(usuario TEXT, nombres TEXT, cvedepto INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT usuario, nombres, cvedepto FROM usuarios WHERE fecbaj IS NULL;
END;
$$ LANGUAGE plpgsql;