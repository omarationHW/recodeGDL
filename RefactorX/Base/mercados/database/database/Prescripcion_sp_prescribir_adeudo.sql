-- Stored Procedure: sp_prescribir_adeudo
-- Tipo: CRUD
-- Descripción: Prescribe (o condona) un adeudo de energía eléctrica, moviendo el registro de ta_11_adeudo_energ a ta_11_ade_ene_canc y eliminando el adeudo original.
-- Generado para formulario: Prescripcion
-- Fecha: 2025-08-27 00:31:46

CREATE OR REPLACE FUNCTION sp_prescribir_adeudo(
    p_id_energia integer,
    p_axo smallint,
    p_periodo smallint,
    p_cve_consumo varchar,
    p_cantidad numeric,
    p_importe numeric,
    p_clave_canc varchar,
    p_observacion varchar,
    p_id_usuario integer
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_11_ade_ene_canc (
        id_cancelacion, id_energia, axo, periodo, cve_consumo, cantidad, importe, clave_canc, observacion, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_energia, p_axo, p_periodo, p_cve_consumo, p_cantidad, p_importe, p_clave_canc, p_observacion, NOW(), p_id_usuario
    );
    DELETE FROM ta_11_adeudo_energ
    WHERE id_energia = p_id_energia AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;