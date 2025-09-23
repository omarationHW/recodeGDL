-- Stored Procedure: deshacer_condonacion_local
-- Tipo: CRUD
-- Descripción: Deshace una condonación, regresando el adeudo a la tabla de adeudos y borrando de condonados.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 23:10:57

CREATE OR REPLACE FUNCTION deshacer_condonacion_local(
    p_id_local integer,
    p_axo smallint,
    p_periodo smallint,
    p_importe numeric,
    p_id_usuario integer,
    p_fecha timestamp,
    p_id_cancelacion integer,
    p_observacion varchar
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_11_adeudo_local (
        id_adeudo_local, id_local, axo, periodo, importe, fecha_alta, id_usuario
    ) VALUES (
        DEFAULT, p_id_local, p_axo, p_periodo, p_importe, p_fecha, p_id_usuario
    );
    DELETE FROM ta_11_ade_loc_canc
    WHERE id_cancelacion = p_id_cancelacion;
END;
$$ LANGUAGE plpgsql;