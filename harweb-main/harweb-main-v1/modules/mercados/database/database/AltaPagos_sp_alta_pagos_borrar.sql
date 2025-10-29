-- Stored Procedure: sp_alta_pagos_borrar
-- Tipo: CRUD
-- Descripción: Elimina un pago y regenera el adeudo si corresponde.
-- Generado para formulario: AltaPagos
-- Fecha: 2025-08-26 20:25:40

CREATE OR REPLACE FUNCTION sp_alta_pagos_borrar(
    p_id_local integer, p_axo integer, p_periodo integer, p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_pago RECORD;
    v_adeudo_count integer;
BEGIN
    SELECT * INTO v_pago FROM ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
    IF FOUND THEN
        -- Regenerar adeudo si no existe
        SELECT COUNT(*) INTO v_adeudo_count FROM ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        IF v_adeudo_count = 0 THEN
            INSERT INTO ta_11_adeudo_local (id_local, axo, periodo, importe, fecha_alta, id_usuario)
            VALUES (p_id_local, p_axo, p_periodo, v_pago.importe_pago, NOW(), p_id_usuario);
        END IF;
        DELETE FROM ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
        RETURN QUERY SELECT true, 'Se Eliminó Correctamente el Pago';
    ELSE
        RETURN QUERY SELECT false, 'No existe el pago a borrar';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al Borrar el Pago: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;