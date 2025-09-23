-- Stored Procedure: sp_get_renta_local
-- Tipo: Catalog
-- Descripción: Obtiene la renta de un local para un año, categoría, sección y clave de cuota.
-- Generado para formulario: RptAdeudosLocales
-- Fecha: 2025-08-27 00:42:39

CREATE OR REPLACE FUNCTION sp_get_renta_local(p_axo integer, p_categoria integer, p_seccion varchar, p_clave_cuota integer)
RETURNS TABLE(
    importe_cuota numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT importe_cuota
    FROM ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;