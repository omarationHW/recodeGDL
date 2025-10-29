-- Stored Procedure: sp_autorizades_baja
-- Tipo: CRUD
-- Descripción: Da de baja (cancela) un descuento autorizado.
-- Generado para formulario: AutorizaDes
-- Fecha: 2025-08-27 13:32:56

CREATE OR REPLACE FUNCTION sp_autorizades_baja(
    p_id_control INTEGER,
    p_fecha_baja DATE,
    p_usuario_id INTEGER,
    p_motivo TEXT DEFAULT NULL
) RETURNS TABLE (ok BOOLEAN, msg TEXT) AS $$
BEGIN
    UPDATE ta_15_autorizados
    SET fecha_baja = p_fecha_baja, id_usuario = p_usuario_id, estado = 2, fecha_actual = NOW(), observaciones = p_motivo
    WHERE control = p_id_control AND estado = 1;
    -- Opcional: poner porcentaje_multa en 100
    UPDATE ta_15_apremios SET porcentaje_multa = 100 WHERE id_control = p_id_control AND porcentaje_multa < 100;
    RETURN QUERY SELECT TRUE, 'Baja exitosa';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;