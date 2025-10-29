-- Stored Procedure: sp_consultar_pagos_energia_elec
-- Tipo: Report
-- Descripción: Consulta los pagos realizados para un id_energia
-- Generado para formulario: CargaPagEnergiaElec
-- Fecha: 2025-08-26 22:53:19

CREATE OR REPLACE FUNCTION sp_consultar_pagos_energia_elec(
    p_id_energia integer
) RETURNS TABLE(
    id_pago_energia integer,
    id_energia integer,
    axo integer,
    periodo integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago varchar,
    operacion_pago integer,
    importe_pago numeric,
    cve_consumo varchar,
    cantidad numeric,
    folio varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_energia, id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, cve_consumo, cantidad, folio
    FROM ta_11_pago_energia
    WHERE id_energia = p_id_energia
    ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;