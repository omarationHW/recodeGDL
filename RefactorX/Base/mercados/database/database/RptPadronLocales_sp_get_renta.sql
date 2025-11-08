-- Stored Procedure: sp_get_renta
-- Tipo: Report
-- Descripción: Obtiene la cuota de renta para un local según año, categoría, sección y clave de cuota.
-- Generado para formulario: RptPadronLocales
-- Fecha: 2025-08-27 01:27:45

CREATE OR REPLACE FUNCTION sp_get_renta(p_axo INTEGER, p_categoria INTEGER, p_seccion VARCHAR, p_clave_cuota INTEGER)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC(12,2),
    fecha_alta TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota, fecha_alta, id_usuario
    FROM ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;