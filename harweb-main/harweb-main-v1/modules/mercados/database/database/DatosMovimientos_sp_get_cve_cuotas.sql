-- Stored Procedure: sp_get_cve_cuotas
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de claves de cuota.
-- Generado para formulario: DatosMovimientos
-- Fecha: 2025-08-26 23:46:08

CREATE OR REPLACE FUNCTION sp_get_cve_cuotas()
RETURNS TABLE (
    clave_cuota SMALLINT,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT clave_cuota, descripcion
    FROM ta_11_cve_cuota
    ORDER BY clave_cuota;
END;
$$ LANGUAGE plpgsql;