-- Stored Procedure: get_giro_descripcion
-- Tipo: Catalog
-- Descripción: Obtiene la descripción del giro por id_giro.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-27 16:06:44

CREATE OR REPLACE FUNCTION get_giro_descripcion(p_id_giro integer)
RETURNS TABLE (
    id_giro integer,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_giro, descripcion FROM c_giros WHERE id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;