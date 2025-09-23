-- Stored Procedure: sp_get_usuario
-- Tipo: Catalog
-- Descripción: Obtiene los datos del usuario
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_usuario(p_id_usuario INTEGER)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado VARCHAR(1),
    id_rec SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec
    FROM ta_12_passwords
    WHERE id_usuario = p_id_usuario;
END;
$$ LANGUAGE plpgsql;