-- Stored Procedure: sp_get_giro_by_id
-- Tipo: Catalog
-- Descripción: Obtiene la descripción del giro por su ID.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-26 14:42:36

CREATE OR REPLACE FUNCTION sp_get_giro_by_id(p_id_giro INTEGER)
RETURNS TABLE (
    id_giro INTEGER,
    descripcion VARCHAR(255)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;