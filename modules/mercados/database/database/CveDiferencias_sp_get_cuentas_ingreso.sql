-- Stored Procedure: sp_get_cuentas_ingreso
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cuentas de ingreso para selección.
-- Generado para formulario: CveDiferencias
-- Fecha: 2025-08-26 23:39:54

CREATE OR REPLACE FUNCTION sp_get_cuentas_ingreso()
RETURNS TABLE (
    cta_aplicacion integer,
    descripcion varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cta_aplicacion, descripcion FROM ta_12_cuentas_aplicacion ORDER BY cta_aplicacion;
END;
$$ LANGUAGE plpgsql;