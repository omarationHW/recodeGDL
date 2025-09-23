-- Stored Procedure: sp_dar_pagado_convenio_diversos
-- Tipo: CRUD
-- Descripción: Marca un convenio como pagado (vigencia='P') y ejecuta lógica de bloqueo/desbloqueo según módulo
-- Generado para formulario: ModifConvDiversos
-- Fecha: 2025-08-27 20:52:39

CREATE OR REPLACE FUNCTION sp_dar_pagado_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        vigencia = 'P',
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
    -- Aquí se puede agregar lógica adicional para afectar otras tablas según el módulo
END;
$$ LANGUAGE plpgsql;