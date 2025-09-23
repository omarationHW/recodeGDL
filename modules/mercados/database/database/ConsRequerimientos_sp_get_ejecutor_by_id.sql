-- Stored Procedure: sp_get_ejecutor_by_id
-- Tipo: Catalog
-- Descripción: Obtiene el ejecutor por clave
-- Generado para formulario: ConsRequerimientos
-- Fecha: 2025-08-26 23:23:01

CREATE OR REPLACE FUNCTION sp_get_ejecutor_by_id(
    p_ejecutor integer
)
RETURNS TABLE (
    cve_eje integer,
    nombre varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT cve_eje, nombre FROM ta_15_ejecutores WHERE cve_eje = p_ejecutor;
END;
$$ LANGUAGE plpgsql;