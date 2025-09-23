-- Stored Procedure: sp_get_resumen_totales_pagos_diversos
-- Tipo: Report
-- Descripción: Obtiene resumen de totales pagado, recargos, intereses para un id_conv_resto
-- Generado para formulario: DetallePagosDiversos
-- Fecha: 2025-08-27 14:22:21

CREATE OR REPLACE FUNCTION sp_get_resumen_totales_pagos_diversos(p_id_conv_resto INTEGER)
RETURNS TABLE (
    total_pagado NUMERIC(18,2),
    total_recargos NUMERIC(18,2),
    total_intereses NUMERIC(18,2)
) AS $$
DECLARE
    totpago NUMERIC(18,2) := 0;
    totbonif NUMERIC(18,2) := 0;
    totintereses NUMERIC(18,2) := 0;
BEGIN
    FOR rec IN SELECT importe_pago, importe_recargo, (SELECT COALESCE(SUM(importe),0) FROM ta_12_recibosdet WHERE fecha=a.fecha_pago AND id_rec=a.oficina_pago AND caja=a.caja_pago AND operacion=a.operacion_pago AND cuenta IN (46508,550200000,551100000)) AS intereses FROM ta_17_conv_pagos a WHERE id_conv_resto = p_id_conv_resto
    LOOP
        totpago := totpago + COALESCE(rec.importe_pago,0);
        totbonif := totbonif + COALESCE(rec.importe_recargo,0);
        totintereses := totintereses + COALESCE(rec.intereses,0);
    END LOOP;
    RETURN QUERY SELECT totpago, totbonif, totintereses;
END;
$$ LANGUAGE plpgsql;