-- Stored Procedure: sp_get_renta_1998
-- Tipo: Report
-- Descripción: Obtiene la renta para un local en 1998 según categoría, sección y clave de cuota.
-- Generado para formulario: RptAdeudosAbastos1998
-- Fecha: 2025-08-27 00:37:50

CREATE OR REPLACE FUNCTION sp_get_renta_1998(p_vaxo integer, p_vcat smallint, p_vsec varchar, p_vcve smallint)
RETURNS TABLE(
    id_cuotas integer,
    axo smallint,
    categoria smallint,
    seccion varchar,
    clave_cuota smallint,
    importe_cuota numeric,
    fecha_alta timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_vaxo AND categoria = p_vcat AND seccion = p_vsec AND clave_cuota = p_vcve;
END;
$$ LANGUAGE plpgsql;