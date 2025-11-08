-- Stored Procedure: sp_get_cuota_by_params
-- Tipo: Catalog
-- Descripción: Obtiene la cuota de un local según parámetros de año, categoría, sección y clave de cuota.
-- Generado para formulario: DatosMovimientos
-- Fecha: 2025-08-26 23:46:08

CREATE OR REPLACE FUNCTION sp_get_cuota_by_params(
    p_vaxo SMALLINT,
    p_vcat SMALLINT,
    p_vsec VARCHAR,
    p_vcuo SMALLINT
)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR,
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_vaxo AND categoria = p_vcat AND seccion = p_vsec AND clave_cuota = p_vcuo;
END;
$$ LANGUAGE plpgsql;