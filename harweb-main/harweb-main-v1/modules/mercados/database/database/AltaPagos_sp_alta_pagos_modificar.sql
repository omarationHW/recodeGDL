-- Stored Procedure: sp_alta_pagos_modificar
-- Tipo: CRUD
-- Descripción: Modifica un pago existente.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_alta_pagos_modificar(
    p_id_local integer, p_axo integer, p_periodo integer, p_fecha_pago date, p_oficina_pago integer, p_caja_pago text, p_operacion_pago integer, p_importe_pago numeric, p_folio text, p_id_usuario integer, p_fecha_ingreso date
) RETURNS TABLE(success boolean, message text) AS $$
BEGIN
    UPDATE ta_11_pagos_local
    SET fecha_pago = p_fecha_pago,
        oficina_pago = p_oficina_pago,
        caja_pago = p_caja_pago,
        operacion_pago = p_operacion_pago,
        importe_pago = p_importe_pago,
        folio = p_folio,
        fecha_modificacion = NOW(),
        id_usuario = p_id_usuario
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT true, 'El Pago Modificó Correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al Modificar el Pago: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;