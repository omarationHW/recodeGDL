-- Stored Procedure: sp_reqtransm_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de requerimiento de transmisión patrimonial
-- Generado para formulario: ReqTrans
-- Fecha: 2025-08-27 15:05:46

CREATE OR REPLACE FUNCTION sp_reqtransm_update(
    p_id integer,
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
) RETURNS boolean AS $$
BEGIN
    UPDATE reqtransm SET
        folioreq = p_folioreq,
        tipo = p_tipo,
        cvecta = p_cvecta,
        cveejec = p_cveejec,
        fecemi = p_fecemi,
        importe = p_importe,
        recargos = p_recargos,
        multas_ex = p_multas_ex,
        multas_otr = p_multas_otr,
        gastos = p_gastos,
        gastos_req = p_gastos_req,
        total = p_total,
        observ = p_observ,
        fecha_actual = now(),
        usu_act = p_usu_act
    WHERE id = p_id;
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;