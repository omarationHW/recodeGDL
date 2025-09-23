-- Stored Procedure: sp_get_version_detalle
-- Tipo: Catalog
-- Descripción: Obtiene detalles de la versión de un proyecto.
-- Generado para formulario: Modulo
-- Fecha: 2025-08-27 14:38:06

CREATE OR REPLACE FUNCTION sp_get_version_detalle(p_proyecto VARCHAR, p_version VARCHAR)
RETURNS TABLE(
    proyecto VARCHAR,
    version VARCHAR,
    fecha DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT proyecto, version, fecha
    FROM ta_versiones
    WHERE proyecto = p_proyecto AND version = p_version;
END;
$$ LANGUAGE plpgsql;