-- Stored Procedure: sp_get_adeudos_by_predio
-- Tipo: Catalog
-- Descripción: Obtiene los adeudos vencidos de un predio/convenio
-- Generado para formulario: IndividualPredios
-- Fecha: 2025-08-27 14:45:56

CREATE OR REPLACE FUNCTION sp_get_adeudos_by_predio(p_id_conv_resto INTEGER, p_fecha DATE)
RETURNS TABLE (
    id_conv_resto INTEGER,
    pago_parcial SMALLINT,
    importe NUMERIC,
    fecha_venc DATE,
    recargos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT ad.id_conv_resto, ad.pago_parcial, ad.importe, ad.fecha_venc,
           COALESCE(sp_calc_recargos_adeudo(ad.id_conv_resto, ad.importe, ad.fecha_venc, p_fecha), 0) AS recargos
    FROM ta_17_adeudos_div ad
    WHERE ad.id_conv_resto = p_id_conv_resto
      AND ad.fecha_venc < p_fecha
      AND ad.clave_pago IS NULL
    ORDER BY ad.id_conv_resto, ad.pago_parcial;
END;
$$ LANGUAGE plpgsql;