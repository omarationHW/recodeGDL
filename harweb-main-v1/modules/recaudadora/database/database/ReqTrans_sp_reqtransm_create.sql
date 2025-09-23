-- Stored Procedure: sp_reqtransm_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de requerimiento de transmisión patrimonial
-- Generado para formulario: ReqTrans
-- Fecha: 2025-08-27 15:05:46

CREATE OR REPLACE FUNCTION sp_reqtransm_create(
    p_folioreq integer,
    p_tipo varchar,
    p_cvecta integer,
    p_cveejec integer,
    p_fecemi date,
    p_importe numeric,
    p_recargos numeric,
    p_multas_ex numeric,
    p_multas_otr numeric,
    p_gastos numeric,
    p_gastos_req numeric,
    p_total numeric,
    p_observ text,
    p_usu_act varchar
) RETURNS integer AS $$
DECLARE
    v_id integer;
BEGIN
    INSERT INTO reqtransm (
        folioreq, tipo, cvecta, cveejec, fecemi, importe, recargos, multas_ex, multas_otr, gastos, gastos_req, total, observ, fecha_actual, usu_act, vigencia
    ) VALUES (
        p_folioreq, p_tipo, p_cvecta, p_cveejec, p_fecemi, p_importe, p_recargos, p_multas_ex, p_multas_otr, p_gastos, p_gastos_req, p_total, p_observ, now(), p_usu_act, 'V'
    ) RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;