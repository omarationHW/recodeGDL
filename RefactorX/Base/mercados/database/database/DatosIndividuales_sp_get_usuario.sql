-- Stored Procedure: sp_get_usuario
-- Tipo: Catalog
-- Descripción: Obtiene los datos del usuario
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

DROP FUNCTION IF EXISTS sp_get_usuario(INTEGER);

CREATE OR REPLACE FUNCTION sp_get_usuario(p_id_usuario INTEGER)
RETURNS TABLE (
    id INTEGER,
    usuario VARCHAR(20),
    nombre VARCHAR(100),
    estado CHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id, a.usuario, a.nombre, a.estado, a.id_rec, a.nivel
    FROM public.usuarios a
    WHERE a.id = p_id_usuario;
END;
$$ LANGUAGE plpgsql;