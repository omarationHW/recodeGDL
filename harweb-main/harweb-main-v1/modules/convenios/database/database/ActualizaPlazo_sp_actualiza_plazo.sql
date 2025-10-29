-- Stored Procedure: sp_actualiza_plazo
-- Tipo: CRUD
-- Descripción: Inserta registros de ampliación de plazo en ta_17_amp_plazo.
-- Generado para formulario: ActualizaPlazo
-- Fecha: 2025-08-27 13:36:02

-- PostgreSQL stored procedure para insertar ampliaciones de plazo
CREATE OR REPLACE PROCEDURE sp_actualiza_plazo(
    p_id_convenio integer,
    p_axo_oficio integer,
    p_folio_oficio varchar,
    p_expediente varchar,
    p_saldo numeric,
    p_recargos numeric,
    p_total numeric,
    p_pago_inicial numeric,
    p_pago_parcial numeric,
    p_pagos integer,
    p_pago_final numeric,
    p_tipo_pago varchar,
    p_fecha_inicio date,
    p_fecha_fin date,
    p_observaciones text,
    p_id_usuario integer,
    p_fecha_act timestamp,
    p_fecha_vencimiento date
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ta_17_amp_plazo (
        id_convenio, axo_oficio, folio_oficio, expediente, saldo, recargos, total, pago_inicial, pago_parcial, pagos, pago_final, tipo_pago, fecha_inicio, fecha_fin, observaciones, id_usuario, fecha_actual, fecha_act, fecha_vencimiento
    ) VALUES (
        p_id_convenio, p_axo_oficio, p_folio_oficio, p_expediente, p_saldo, p_recargos, p_total, p_pago_inicial, p_pago_parcial, p_pagos, p_pago_final, p_tipo_pago, p_fecha_inicio, p_fecha_fin, p_observaciones, p_id_usuario, now(), p_fecha_act, p_fecha_vencimiento
    );
END;
$$;