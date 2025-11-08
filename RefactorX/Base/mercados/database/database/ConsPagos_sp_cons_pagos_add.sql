-- Stored Procedure: sp_cons_pagos_add
-- Tipo: CRUD
-- Descripción: Agrega un pago a un local.
-- Generado para formulario: ConsPagos
-- Fecha: 2025-08-27 16:01:41

CREATE OR REPLACE FUNCTION sp_cons_pagos_add(
    p_id_local INTEGER,
    p_axo SMALLINT,
    p_periodo SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago VARCHAR(10),
    p_operacion_pago INTEGER,
    p_importe_pago NUMERIC(12,2),
    p_folio VARCHAR(50),
    p_id_usuario INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_id_pago_local INTEGER;
BEGIN
    INSERT INTO ta_11_pagos_local (
        id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario
    ) VALUES (
        p_id_local, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_folio, NOW(), p_id_usuario
    ) RETURNING id_pago_local INTO v_id_pago_local;
    RETURN v_id_pago_local;
END;
$$ LANGUAGE plpgsql;