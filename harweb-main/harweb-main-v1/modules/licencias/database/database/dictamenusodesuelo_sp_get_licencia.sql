-- Stored Procedure: sp_get_licencia
-- Tipo: Catalog
-- Descripción: Obtiene datos de una licencia por id_licencia o licencia
-- Generado para formulario: dictamenusodesuelo
-- Fecha: 2025-08-26 16:07:52

CREATE OR REPLACE FUNCTION sp_get_licencia(
    p_id_licencia integer DEFAULT NULL,
    p_licencia integer DEFAULT NULL
) RETURNS TABLE(
    id_licencia integer,
    licencia integer,
    propietario varchar,
    actividad varchar,
    ubicacion varchar,
    sup_construida double precision,
    sup_autorizada double precision,
    num_cajones integer,
    num_empleados integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_licencia, licencia, propietario, actividad, ubicacion, sup_construida, sup_autorizada, num_cajones, num_empleados
    FROM licencias
    WHERE (p_id_licencia IS NULL OR id_licencia = p_id_licencia)
      AND (p_licencia IS NULL OR licencia = p_licencia)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;