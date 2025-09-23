-- Stored Procedure: sp_bloquear_convenio_diversos
-- Tipo: CRUD
-- Descripción: Bloquea un convenio diversos (bloqueo=1)
-- Generado para formulario: ModifConvDiversos
-- Fecha: 2025-08-27 20:52:39

CREATE OR REPLACE FUNCTION sp_bloquear_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_observaciones VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        bloqueo = 1,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;