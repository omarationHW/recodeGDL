-- Stored Procedure: usuario_info_get
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por id_usuario.
-- Generado para formulario: PagosIndividual
-- Fecha: 2025-08-27 00:24:24

CREATE OR REPLACE FUNCTION usuario_info_get(p_id_usuario integer)
RETURNS TABLE (
    id_usuario integer,
    usuario varchar,
    nombre varchar,
    estado varchar,
    id_rec smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec
    FROM ta_12_passwords
    WHERE id_usuario = p_id_usuario
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;