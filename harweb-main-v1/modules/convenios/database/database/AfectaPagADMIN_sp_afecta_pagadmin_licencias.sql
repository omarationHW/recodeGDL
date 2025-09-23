-- Stored Procedure: sp_afecta_pagadmin_licencias
-- Tipo: CRUD
-- Descripción: Afecta el pago de licencias o anuncios
-- Generado para formulario: AfectaPagADMIN
-- Fecha: 2025-08-27 13:39:58

CREATE OR REPLACE FUNCTION sp_afecta_pagadmin_licencias(p_id_pago INT, p_usuario VARCHAR)
RETURNS JSON AS $$
DECLARE
    pago RECORD;
    result JSON;
BEGIN
    SELECT * INTO pago FROM pagos_admin WHERE id_recibo = p_id_pago;
    IF pago.estado = 'V' THEN
        IF pago.modulo = 9 THEN
            -- Afecta como pagada la licencia
            PERFORM conv_licanun(pago.id_referencia, 'L', 'P', pago.id_convenio, p_usuario);
        ELSIF pago.modulo = 10 THEN
            -- Afecta como pagado el anuncio
            PERFORM conv_licanun(pago.id_referencia, 'A', 'P', pago.id_convenio, p_usuario);
        END IF;
        -- Afecta como pagado el convenio
        UPDATE convenios SET vigencia = 'P' WHERE id_conv_diver = pago.id_convenio;
    ELSIF pago.estado = 'C' THEN
        IF pago.modulo = 9 THEN
            -- Reactiva el adeudo/bloqueo de licencias
            PERFORM conv_licanun(pago.id_referencia, 'L', 'A', pago.id_convenio, p_usuario);
        ELSIF pago.modulo = 10 THEN
            -- Reactiva el adeudo/bloqueo del anuncio
            PERFORM conv_licanun(pago.id_referencia, 'A', 'A', pago.id_convenio, p_usuario);
        END IF;
        -- Reactiva el convenio
        UPDATE convenios SET vigencia = 'A' WHERE id_conv_diver = pago.id_convenio;
    END IF;
    result := json_build_object('success', true, 'message', 'Licencias/Anuncios afectados correctamente');
    RETURN result;
EXCEPTION WHEN OTHERS THEN
    result := json_build_object('success', false, 'message', SQLERRM);
    RETURN result;
END;
$$ LANGUAGE plpgsql;