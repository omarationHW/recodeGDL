-- Stored Procedure: sp_passwords_list
-- Tipo: Catalog
-- Descripción: Lista los registros de ta_12_passwords filtrando por usuario (si se provee).
-- Generado para formulario: Dspasswords
-- Fecha: 2025-08-27 13:35:26

CREATE OR REPLACE FUNCTION sp_passwords_list(p_usuario VARCHAR)
RETURNS TABLE (
    id_usuario INTEGER,
    usuario VARCHAR(10),
    nombre VARCHAR(50),
    estado CHAR(1),
    id_rec SMALLINT,
    nivel SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords
    WHERE (p_usuario IS NULL OR usuario = p_usuario);
END;
$$ LANGUAGE plpgsql;