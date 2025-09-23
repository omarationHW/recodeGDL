-- Stored Procedure: sp_get_pago_parcialidad
-- Tipo: Catalog
-- Descripción: Obtiene el registro de pago de una parcialidad específica de un convenio.
-- Generado para formulario: DatosConvenio
-- Fecha: 2025-08-27 14:34:07

CREATE OR REPLACE FUNCTION sp_get_pago_parcialidad(p_id_conv_resto INTEGER, p_parcial INTEGER)
RETURNS TABLE (
    id_conv_resto INTEGER,
    pago_parcial SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago CHAR(2),
    operacion_pago INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_conv_resto, pago_parcial, fecha_pago, oficina_pago, caja_pago, operacion_pago
    FROM ta_17_conv_pagos
    WHERE id_conv_resto = p_id_conv_resto AND pago_parcial = p_parcial;
END;
$$ LANGUAGE plpgsql;