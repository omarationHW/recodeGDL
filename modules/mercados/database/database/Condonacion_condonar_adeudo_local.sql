-- Stored Procedure: condonar_adeudo_local
-- Tipo: CRUD
-- Descripción: Condona un adeudo específico de un local (mueve de adeudo a tabla de condonados).
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 23:10:57

CREATE OR REPLACE FUNCTION condonar_adeudo_local(
    p_id_local integer,
    p_axo smallint,
    p_periodo smallint,
    p_importe numeric,
    p_clave_canc varchar,
    p_observacion varchar,
    p_id_usuario integer,
    p_fecha timestamp
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_11_ade_loc_canc (
        id_cancelacion, id_local, axo, periodo, importe, clave_canc, observacion, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_local, p_axo, p_periodo, p_importe, p_clave_canc, p_observacion, p_fecha, p_id_usuario
    );
    DELETE FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;