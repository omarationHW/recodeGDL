-- Stored Procedure: sp_get_cuota
-- Tipo: Catalog
-- Descripción: Obtiene la cuota del local
-- Generado para formulario: DatosIndividuales
-- Fecha: 2025-08-26 23:44:50

CREATE OR REPLACE FUNCTION sp_get_cuota(p_axo SMALLINT, p_categoria SMALLINT, p_seccion VARCHAR, p_clave_cuota SMALLINT)
RETURNS TABLE (
    id_cuotas INTEGER,
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC,
    renta NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_cuotas, axo, categoria, seccion, clave_cuota, importe_cuota,
        importe_cuota AS renta
    FROM ta_11_cuo_locales
    WHERE axo = p_axo AND categoria = p_categoria AND seccion = p_seccion AND clave_cuota = p_clave_cuota;
END;
$$ LANGUAGE plpgsql;