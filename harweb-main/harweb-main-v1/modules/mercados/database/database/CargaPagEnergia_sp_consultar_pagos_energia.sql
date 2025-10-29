-- Stored Procedure: sp_consultar_pagos_energia
-- Tipo: Report
-- Descripción: Consulta los pagos realizados para un id_energia.
-- Generado para formulario: CargaPagEnergia
-- Fecha: 2025-08-26 22:51:22

CREATE OR REPLACE FUNCTION sp_consultar_pagos_energia(
    p_id_energia INTEGER
) RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo INTEGER,
    periodo INTEGER,
    fecha_pago DATE,
    oficina_pago INTEGER,
    caja_pago VARCHAR,
    operacion_pago INTEGER,
    importe_pago NUMERIC,
    cve_consumo VARCHAR,
    cantidad NUMERIC,
    folio VARCHAR,
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio, fecha_modificacion, id_usuario
    FROM ta_11_pago_energia
    WHERE id_energia = p_id_energia
    ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;