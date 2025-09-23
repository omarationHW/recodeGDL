-- Stored Procedure: sp_condonacion_deshacer_condonacion
-- Tipo: CRUD
-- Descripción: Deshace la condonación de un adeudo, restaurando el adeudo original.
-- Generado para formulario: Condonacion
-- Fecha: 2025-08-26 19:19:54

CREATE OR REPLACE PROCEDURE sp_condonacion_deshacer_condonacion(
    p_id_local integer,
    p_axo integer,
    p_periodo integer,
    p_importe numeric,
    p_id_usuario integer,
    p_fecha_alta timestamp,
    p_id_cancelacion integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_11_adeudo_local (id_local, axo, periodo, importe, fecha_alta, id_usuario)
    VALUES (p_id_local, p_axo, p_periodo, p_importe, p_fecha_alta, p_id_usuario);
    DELETE FROM ta_11_ade_loc_canc
    WHERE id_cancelacion = p_id_cancelacion;
END;
$$;