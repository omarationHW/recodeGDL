-- Stored Procedure: sp_cat_cta_aplicacion_exists
-- Tipo: Catalog
-- Descripción: Verifica si existe la cuenta de aplicación.
-- Generado para formulario: Mannto_Tipos_Aseo
-- Fecha: 2025-08-27 14:50:41

CREATE OR REPLACE FUNCTION sp_cat_cta_aplicacion_exists(p_cta integer)
RETURNS TABLE(exists boolean) AS $$
BEGIN
    RETURN QUERY SELECT EXISTS(SELECT 1 FROM ta_12_cuentas WHERE cta_aplicacion = p_cta);
END;
$$ LANGUAGE plpgsql;