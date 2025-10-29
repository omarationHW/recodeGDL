-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ActualizaPlazo
-- Generado: 2025-08-27 13:36:02
-- Total SPs: 2
-- ============================================

-- SP 1/2: spd_17_calc_fechav
-- Tipo: CRUD
-- Descripción: Calcula la fecha de vencimiento para ampliación de plazo de convenio.
-- --------------------------------------------

-- PostgreSQL stored procedure para calcular fecha de vencimiento
CREATE OR REPLACE FUNCTION spd_17_calc_fechav(
    parm_colonia integer,
    parm_calle integer,
    parm_folio integer,
    parm_fecha_inicio date,
    parm_parcialidad integer,
    parm_tipo varchar
) RETURNS TABLE(expression integer, expression_1 date) AS $$
DECLARE
    v_id_convenio integer;
    v_fecha_venc date;
BEGIN
    -- Buscar el id_convenio
    SELECT id_convenio INTO v_id_convenio
    FROM ta_17_convenios
    WHERE colonia = parm_colonia AND calle = parm_calle AND folio = parm_folio
    LIMIT 1;
    -- Calcular fecha de vencimiento (ejemplo: sumar meses/quincenas/semanas)
    IF parm_tipo = 'M' THEN
        v_fecha_venc := parm_fecha_inicio + INTERVAL '1 month' * parm_parcialidad;
    ELSIF parm_tipo = 'Q' THEN
        v_fecha_venc := parm_fecha_inicio + INTERVAL '15 days' * parm_parcialidad;
    ELSIF parm_tipo = 'S' THEN
        v_fecha_venc := parm_fecha_inicio + INTERVAL '7 days' * parm_parcialidad;
    ELSE
        v_fecha_venc := parm_fecha_inicio;
    END IF;
    RETURN QUERY SELECT v_id_convenio, v_fecha_venc::date;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_actualiza_plazo
-- Tipo: CRUD
-- Descripción: Inserta registros de ampliación de plazo en ta_17_amp_plazo.
-- --------------------------------------------

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

-- ============================================

