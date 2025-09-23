-- Stored Procedure: sp_insert_con_reg_pred
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta_17_con_reg_pred y retorna el id
-- Generado para formulario: PasoConvDiversos
-- Fecha: 2025-08-27 15:12:01

CREATE OR REPLACE FUNCTION sp_insert_con_reg_pred(
    p_tipo integer,
    p_subtipo integer,
    p_manzana text,
    p_lote integer,
    p_letra text,
    p_id_usuario integer,
    p_fecha_actual timestamp,
    p_usuario integer
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO ta_17_con_reg_pred (tipo, subtipo, manzana, lote, letra, id_usuario, fecha_actual)
    VALUES (p_tipo, p_subtipo, p_manzana, p_lote, NULLIF(p_letra, 'null'), p_id_usuario, p_fecha_actual)
    RETURNING id_conv_predio INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;