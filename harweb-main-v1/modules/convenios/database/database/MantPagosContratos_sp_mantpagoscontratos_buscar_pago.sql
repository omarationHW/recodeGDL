-- Stored Procedure: sp_mantpagoscontratos_buscar_pago
-- Tipo: CRUD
-- Descripción: Busca un pago de contrato por fecha, oficina, caja y operación.
-- Generado para formulario: MantPagosContratos
-- Fecha: 2025-08-27 14:54:01

CREATE OR REPLACE FUNCTION sp_mantpagoscontratos_buscar_pago(
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER
) RETURNS TABLE (
    id_pago INTEGER,
    id_convenio INTEGER,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    pago_parcial SMALLINT,
    total_parciales SMALLINT,
    importe NUMERIC,
    cve_descuento SMALLINT,
    cve_bonificacion SMALLINT,
    id_usuario INTEGER,
    fecha_actual TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM ta_17_pagos
    WHERE fecha_pago = p_fecha_pago
      AND oficina_pago = p_oficina_pago
      AND caja_pago = p_caja_pago
      AND operacion_pago = p_operacion_pago;
END;
$$ LANGUAGE plpgsql;