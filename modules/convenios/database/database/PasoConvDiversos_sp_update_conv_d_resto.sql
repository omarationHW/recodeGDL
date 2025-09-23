-- Stored Procedure: sp_update_conv_d_resto
-- Tipo: CRUD
-- Descripción: Actualiza un registro en ta_17_conv_d_resto
-- Generado para formulario: PasoConvDiversos
-- Fecha: 2025-08-27 15:12:01

CREATE OR REPLACE FUNCTION sp_update_conv_d_resto(
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
    UPDATE ta_17_conv_d_resto SET
        id_referencia = p_id_referencia,
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        nombre = p_nombre,
        calle = p_calle,
        num_exterior = p_num_exterior,
        num_interior = p_num_interior,
        inciso = p_inciso,
        fecha_inicio = p_fecha_inicio,
        fecha_venc = p_fecha_venc,
        cantidad_total = p_cantidad_total,
        cantidad_inicio = p_cantidad_inicio,
        pago_parcial = p_pago_parcial,
        pago_final = p_pago_final,
        total_pagos = p_total_pagos,
        metros = p_metros,
        tipo_pago = p_tipo_pago,
        observaciones = p_observaciones,
        vigencia = p_vigencia,
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE tipo = p_tipo AND id_conv_diver = p_id_conv_diver;
END;
$$ LANGUAGE plpgsql;