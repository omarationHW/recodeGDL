-- Stored Procedure: sp_condonacion_condonar_adeudo
-- Tipo: CRUD
-- Descripción: Condona un adeudo específico de un local.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 19:19:54

CREATE OR REPLACE PROCEDURE sp_condonacion_condonar_adeudo(
    p_id_local integer,
    p_axo integer,
    p_periodo integer,
    p_importe numeric,
    p_clave_canc varchar,
    p_observacion varchar,
    p_id_usuario integer,
    p_fecha_alta timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_11_ade_loc_canc (id_local, axo, periodo, importe, clave_canc, observacion, fecha_alta, id_usuario)
    VALUES (p_id_local, p_axo, p_periodo, p_importe, p_clave_canc, p_observacion, p_fecha_alta, p_id_usuario);
    DELETE FROM ta_11_adeudo_local
    WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$;