-- Stored Procedure: sp_consdesgloce_get_cuentas_aplicacion
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de cuentas de aplicación para un año dado
-- Generado para formulario: ConsDesgloce
-- Fecha: 2025-08-27 14:10:10

CREATE OR REPLACE FUNCTION sp_consdesgloce_get_cuentas_aplicacion(p_year INTEGER)
RETURNS TABLE(
    cta_aplic INTEGER,
    descripcion VARCHAR(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cta_aplic, descripcion
    FROM ta_12_ctas_odoo
    WHERE axo = p_year
    ORDER BY cta_aplic;
END;
$$ LANGUAGE plpgsql;