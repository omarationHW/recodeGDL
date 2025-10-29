-- Stored Procedure: sp_list_giros
-- Tipo: Catalog
-- Descripción: Lista los giros disponibles
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-26 16:07:52

CREATE OR REPLACE FUNCTION sp_list_giros(
    p_id_giro integer DEFAULT NULL
) RETURNS TABLE(
    id_giro integer,
    descripcion varchar,
    clasificacion varchar,
    tipo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_giro, descripcion, clasificacion, tipo
    FROM c_giros
    WHERE (p_id_giro IS NULL OR id_giro = p_id_giro);
END;
$$ LANGUAGE plpgsql;