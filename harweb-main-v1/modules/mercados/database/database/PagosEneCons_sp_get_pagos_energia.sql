-- Stored Procedure: sp_get_pagos_energia
-- Tipo: Report
-- Descripción: Obtiene todos los pagos de energía eléctrica para un id_energia.
-- Generado para formulario: PagosEneCons
-- Fecha: 2025-08-27 00:23:09

CREATE OR REPLACE FUNCTION sp_get_pagos_energia(p_id_energia INTEGER)
RETURNS TABLE (
    id_pago_energia INTEGER,
    id_energia INTEGER,
    axo SMALLINT,
    periodo SMALLINT,
    fecha_pago DATE,
    oficina_pago SMALLINT,
    caja_pago VARCHAR(1),
    operacion_pago INTEGER,
    importe_pago NUMERIC(12,2),
    cve_consumo VARCHAR(1),
    cantidad NUMERIC(12,2),
    folio VARCHAR(18),
    fecha_modificacion TIMESTAMP,
    id_usuario INTEGER,
    usuario VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_pago_energia, a.id_energia, a.axo, a.periodo, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.importe_pago, a.cve_consumo, a.cantidad, a.folio, a.fecha_modificacion, a.id_usuario, b.usuario
    FROM ta_11_pago_energia a
    JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
    WHERE a.id_energia = p_id_energia
    ORDER BY a.id_energia ASC, a.axo ASC, a.periodo ASC;
END;
$$ LANGUAGE plpgsql;