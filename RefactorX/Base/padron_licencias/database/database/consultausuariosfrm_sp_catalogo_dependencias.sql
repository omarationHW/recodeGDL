-- Stored Procedure: sp_catalogo_dependencias
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de dependencias ordenado por descripción.
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-26 15:58:09

CREATE OR REPLACE FUNCTION sp_catalogo_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_dependencia, descripcion FROM c_dependencias ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;