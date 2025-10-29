-- Stored Procedure: sp_alta_pagos_agregar
-- Tipo: CRUD
-- Descripción: Agrega un pago de local y elimina el adeudo correspondiente si existe.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_alta_pagos_agregar(
    p_id_local integer, p_axo integer, p_periodo integer, p_fecha_pago date, p_oficina_pago integer, p_caja_pago text, p_operacion_pago integer, p_importe_pago numeric, p_folio text, p_id_usuario integer, p_fecha_ingreso date
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_adeudo_count integer;
BEGIN
    -- Insertar el pago
    INSERT INTO ta_11_pagos_local (id_local, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, folio, fecha_modificacion, id_usuario)
    VALUES (p_id_local, p_axo, p_periodo, p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_importe_pago, p_folio, NOW(), p_id_usuario);
    -- Si existe adeudo, eliminarlo
    SELECT COUNT(*) INTO v_adeudo_count FROM ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF v_adeudo_count = 1 THEN
        DELETE FROM ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    END IF;
    RETURN QUERY SELECT true, 'El Pago se dio de Alta Correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al dar de Alta el Pago: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;