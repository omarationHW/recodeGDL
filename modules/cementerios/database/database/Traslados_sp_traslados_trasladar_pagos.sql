-- Stored Procedure: sp_traslados_trasladar_pagos
-- Tipo: CRUD
-- Descripción: Realiza el traslado de pagos de una ubicación origen a una destino, actualizando los registros correspondientes.
-- Generado para formulario: Traslados
-- Fecha: 2025-08-27 15:19:30

CREATE OR REPLACE FUNCTION sp_traslados_trasladar_pagos(
    p_origen_control_id INTEGER,
    p_destino_cementerio VARCHAR,
    p_destino_clase INTEGER,
    p_destino_clase_alfa VARCHAR,
    p_destino_seccion INTEGER,
    p_destino_seccion_alfa VARCHAR,
    p_destino_linea INTEGER,
    p_destino_linea_alfa VARCHAR,
    p_destino_fosa INTEGER,
    p_destino_fosa_alfa VARCHAR,
    p_destino_control_rcm INTEGER,
    p_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_axo INTEGER;
    v_uap INTEGER;
BEGIN
    -- Actualizar pagos
    UPDATE ta_13_pagosrcm
    SET cementerio = p_destino_cementerio,
        clase = p_destino_clase,
        clase_alfa = COALESCE(p_destino_clase_alfa, ''),
        seccion = p_destino_seccion,
        seccion_alfa = COALESCE(p_destino_seccion_alfa, ''),
        linea = p_destino_linea,
        linea_alfa = COALESCE(p_destino_linea_alfa, ''),
        fosa = p_destino_fosa,
        fosa_alfa = COALESCE(p_destino_fosa_alfa, ''),
        control_rcm = p_destino_control_rcm,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_id = p_origen_control_id;

    -- Actualizar axo_pagado en datosrcm destino
    SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_axo;
    SELECT MAX(axo_pago_hasta) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = p_destino_control_rcm;
    IF v_uap IS NULL OR v_uap = 0 THEN
        v_uap := v_axo - 5;
    END IF;
    UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = p_destino_control_rcm;

    -- Actualizar axo_pagado en datosrcm origen (opcional, según reglas)
    -- SELECT MAX(axo_pago_hasta) INTO v_uap FROM ta_13_pagosrcm WHERE control_rcm = (SELECT control_rcm FROM ta_13_pagosrcm WHERE control_id = p_origen_control_id);
    -- IF v_uap IS NULL OR v_uap = 0 THEN
    --     v_uap := v_axo - 5;
    -- END IF;
    -- UPDATE ta_13_datosrcm SET axo_pagado = v_uap WHERE control_rcm = (SELECT control_rcm FROM ta_13_pagosrcm WHERE control_id = p_origen_control_id);

    RETURN QUERY SELECT TRUE, 'Traslado realizado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al trasladar pagos: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;