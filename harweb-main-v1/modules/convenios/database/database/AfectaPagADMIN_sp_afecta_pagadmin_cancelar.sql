-- Stored Procedure: sp_afecta_pagadmin_cancelar
-- Tipo: CRUD
-- Descripción: Cancela un pago de convenio diverso
-- Generado para formulario: AfectaPagADMIN
-- Fecha: 2025-08-27 13:39:58

CREATE OR REPLACE FUNCTION sp_afecta_pagadmin_cancelar(p_id_pago INT, p_usuario VARCHAR)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Insertar en pagoscan
    INSERT INTO pagoscan VALUES (DEFAULT, p_id_pago, p_usuario, CURRENT_DATE);
    -- Reactivar convenio si corresponde
    UPDATE convenios SET vigencia = 'A' WHERE id_conv_diver = (SELECT id_convenio FROM pagos_admin WHERE id_recibo = p_id_pago);
    result := json_build_object('success', true, 'message', 'Pago cancelado correctamente');
    RETURN result;
EXCEPTION WHEN OTHERS THEN
    result := json_build_object('success', false, 'message', SQLERRM);
    RETURN result;
END;
$$ LANGUAGE plpgsql;