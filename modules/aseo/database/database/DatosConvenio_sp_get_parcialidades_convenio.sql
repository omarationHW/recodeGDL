-- Stored Procedure: sp_get_parcialidades_convenio
-- Tipo: Catalog
-- Descripción: Obtiene las parcialidades (adeudos parciales) de un convenio, incluyendo información de pago.
-- Generado para formulario: DatosConvenio
-- Fecha: 2025-08-27 14:34:07

CREATE OR REPLACE FUNCTION sp_get_parcialidades_convenio(p_id_conv_resto INTEGER)
RETURNS TABLE (
    parcial SMALLINT,
    impuesto_adeudo NUMERIC(18,2),
    periodos VARCHAR(165),
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.pago_parcial AS parcial,
        a.importe AS impuesto_adeudo,
        (a.mes_desde || '/' || a.axo_desde || ' - ' || a.mes_hasta || '/' || a.axo_hasta) AS periodos,
        b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago
    FROM ta_17_adeudos_div a
    LEFT JOIN ta_17_conv_pagos b
      ON b.id_conv_resto = a.id_conv_resto AND b.pago_parcial = a.pago_parcial
    WHERE a.id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;