-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: PASOCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 62_SP_CONVENIOS_PASOCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_insert_con_reg_pred
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta_17_con_reg_pred y retorna el id
-- --------------------------------------------

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
    INSERT INTO public.ta_17_con_reg_pred (tipo, subtipo, manzana, lote, letra, id_usuario, fecha_actual)
    VALUES (p_tipo, p_subtipo, p_manzana, p_lote, NULLIF(p_letra, 'null'), p_id_usuario, p_fecha_actual)
    RETURNING id_conv_predio INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: PASOCONVDIVERSOS (EXACTO del archivo original)
-- Archivo: 62_SP_CONVENIOS_PASOCONVDIVERSOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_update_conv_d_resto
-- Tipo: CRUD
-- Descripción: Actualiza un registro en ta_17_conv_d_resto
-- --------------------------------------------

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
    UPDATE public.ta_17_conv_d_resto SET
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

-- ============================================

