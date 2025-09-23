-- Stored Procedure: sp_get_dia_vencimiento
-- Tipo: Catalog
-- Descripción: Obtiene el día de vencimiento para un predio/convenio en un año y mes dados
-- Generado para formulario: IndividualPredios
-- Fecha: 2025-08-27 14:45:56

CREATE OR REPLACE FUNCTION sp_get_dia_vencimiento(p_id_conv_resto INTEGER, p_anio INTEGER, p_mes INTEGER)
RETURNS TABLE (dia_venc SMALLINT) AS $$
BEGIN
    RETURN QUERY
    SELECT EXTRACT(DAY FROM fecha_venc)::SMALLINT AS dia_venc
    FROM ta_17_adeudos_div
    WHERE id_conv_resto = p_id_conv_resto
      AND EXTRACT(YEAR FROM fecha_venc) = p_anio
      AND EXTRACT(MONTH FROM fecha_venc) = p_mes
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;