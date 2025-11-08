-- Stored Procedure: sp_buscagiro_permisos
-- Tipo: Catalog
-- Descripción: Obtiene los permisos de giros del usuario.
-- Generado para formulario: buscagirofrm
-- Fecha: 2025-08-27 16:26:19

CREATE OR REPLACE FUNCTION sp_buscagiro_permisos(
    p_usuario TEXT,
    p_id_permiso_catalogo INT
)
RETURNS TABLE (
    id INT,
    usuario TEXT,
    giro_a CHAR(1),
    giro_b CHAR(1),
    giro_c CHAR(1),
    giro_d CHAR(1),
    id_permiso_catalogo INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, usuario, giro_a, giro_b, giro_c, giro_d, id_permiso_catalogo
    FROM lic_permisos
    WHERE usuario = p_usuario AND id_permiso_catalogo = p_id_permiso_catalogo;
END;
$$ LANGUAGE plpgsql;