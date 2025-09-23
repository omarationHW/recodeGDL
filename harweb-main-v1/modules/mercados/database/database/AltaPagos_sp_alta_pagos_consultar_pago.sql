-- Stored Procedure: sp_alta_pagos_consultar_pago
-- Tipo: CRUD
-- Descripción: Consulta si existe un pago para un local, año y periodo.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_alta_pagos_consultar_pago(
    p_id_local integer, p_axo integer, p_periodo integer
) RETURNS TABLE(
    id_pago_local integer,
    id_local integer,
    axo integer,
    periodo integer,
    fecha_pago date,
    oficina_pago integer,
    caja_pago text,
    operacion_pago integer,
    importe_pago numeric,
    folio text,
    fecha_modificacion timestamp,
    id_usuario integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_pago_local, id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
    FROM ta_11_pagos_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;