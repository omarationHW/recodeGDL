-- Stored Procedure: sp_insert_conv_d_resto
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta_17_conv_d_resto
-- Generado para formulario: PasoConvDiversos
-- Fecha: 2025-08-27 15:12:01

CREATE OR REPLACE FUNCTION sp_insert_conv_d_resto(
    p_tipo integer,
    p_id_conv_diver integer,
    p_id_referencia integer,
    p_id_rec integer,
    p_id_zona integer,
    p_nombre text,
    p_calle text,
    p_num_exterior integer,
    p_num_interior integer,
    p_inciso text,
    p_fecha_inicio date,
    p_fecha_venc date,
    p_cantidad_total numeric,
    p_cantidad_inicio numeric,
    p_pago_parcial numeric,
    p_pago_final numeric,
    p_total_pagos integer,
    p_metros numeric,
    p_tipo_pago text,
    p_observaciones text,
    p_vigencia text,
    p_id_usuario integer,
    p_fecha_actual timestamp,
    p_usuario integer,
    p_actualizacion timestamp,
    p_letra text,
    p_manzana text,
    p_lote integer,
    p_subtipo integer
) RETURNS void AS $$
BEGIN
    INSERT INTO ta_17_conv_d_resto (
        tipo, id_conv_diver, id_referencia, id_rec, id_zona, nombre, calle, num_exterior, num_interior, inciso,
        fecha_inicio, fecha_venc, cantidad_total, cantidad_inicio, pago_parcial, pago_final, total_pagos, metros,
        tipo_pago, observaciones, vigencia, id_usuario, fecha_actual
    ) VALUES (
        p_tipo, p_id_conv_diver, p_id_referencia, p_id_rec, p_id_zona, p_nombre, p_calle, p_num_exterior, p_num_interior, p_inciso,
        p_fecha_inicio, p_fecha_venc, p_cantidad_total, p_cantidad_inicio, p_pago_parcial, p_pago_final, p_total_pagos, p_metros,
        p_tipo_pago, p_observaciones, p_vigencia, p_id_usuario, p_fecha_actual
    );
END;
$$ LANGUAGE plpgsql;