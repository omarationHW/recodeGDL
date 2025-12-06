-- Stored Procedure: usuario_info_get
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por id_usuario.
-- Generado para formulario: PagosIndividual
-- Fecha: 2025-08-27 00:24:24

CREATE OR REPLACE FUNCTION usuario_info_get(p_id_usuario integer)
RETURNS TABLE (
    id integer,
    usuario varchar(50),
    nombre varchar(100),
    email varchar(100),
    activo boolean
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, usuario, nombre, email, activo
    FROM public.usuarios
    WHERE id = p_id_usuario
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;