-- Stored Procedure: sp_cpe_consultar_pagos
-- Tipo: CRUD
-- Descripción: Consulta pagos de energía eléctrica por fecha, oficina, caja y operación
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 19:52:08

CREATE OR REPLACE FUNCTION sp_cpe_consultar_pagos(
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR,
    p_operacion_pago INTEGER
) RETURNS TABLE(
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    cve_consumo VARCHAR,
    cantidad FLOAT,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    FROM ta_11_pago_energia
    WHERE fecha_pago = p_fecha_pago
      AND oficina_pago = p_oficina_pago
      AND caja_pago = p_caja_pago
      AND operacion_pago = p_operacion_pago;
END;
$$ LANGUAGE plpgsql;