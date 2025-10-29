-- Stored Procedure: sp_bonificaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza una bonificación existente en ta_13_bonifrcm
-- Generado para formulario: Bonificaciones
-- Fecha: 2025-08-28 17:48:25

CREATE OR REPLACE FUNCTION sp_bonificaciones_update(
    p_oficio integer,
    p_axo integer,
    p_doble varchar,
    p_fecha_ofic date,
    p_importe_bonificar numeric,
    p_importe_bonificado numeric,
    p_importe_resto numeric,
    p_usuario integer
) RETURNS void AS $$
BEGIN
    UPDATE ta_13_bonifrcm
    SET fecha_ofic = p_fecha_ofic,
        importe_bonificar = p_importe_bonificar,
        importe_bonificado = p_importe_bonificado,
        importe_resto = p_importe_resto,
        usuario = p_usuario,
        fecha_mov = NOW()
    WHERE oficio = p_oficio AND axo = p_axo AND doble = p_doble;
END;
$$ LANGUAGE plpgsql;