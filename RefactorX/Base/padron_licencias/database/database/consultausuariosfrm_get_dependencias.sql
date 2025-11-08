-- Stored Procedure: get_dependencias
-- Tipo: Catalog
-- Descripción: Devuelve todas las dependencias ordenadas por descripción.
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-27 17:29:11

CREATE OR REPLACE FUNCTION get_dependencias()
RETURNS TABLE (
    id_dependencia integer,
    descripcion varchar,
    clave varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_dependencia, descripcion, clave
    FROM c_dependencias
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;