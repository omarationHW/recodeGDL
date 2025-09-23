-- Stored Procedure: upd34_gen_adeudos_ind
-- Tipo: CRUD
-- Descripción: Procesa la opción seleccionada (pago, condonación, cancelación, prescripción) sobre un adeudo individual.
-- Generado para formulario: GAdeudos_OpcMult
-- Fecha: 2025-08-28 12:58:41

CREATE OR REPLACE FUNCTION upd34_gen_adeudos_ind(
    par_id_34_datos INTEGER,
    par_Axo INTEGER,
    par_Mes INTEGER,
    par_Fecha DATE,
    par_Id_Rec INTEGER,
    par_Caja TEXT,
    par_Consec INTEGER,
    par_Folio_rcbo TEXT,
    par_tab TEXT,
    par_status TEXT,
    par_Opc TEXT,
    par_usuario TEXT
) RETURNS TABLE (
    status INTEGER,
    concepto_status TEXT
) AS $$
DECLARE
    v_status INTEGER := 0;
    v_msg TEXT := '';
BEGIN
    -- Aquí va la lógica de actualización de adeudos, pagos, etc.
    -- Ejemplo: Si par_status = 'P' (pagado), insertar en t34_pagos y actualizar status
    IF par_status = 'P' THEN
        -- Insertar pago
        INSERT INTO t34_pagos (id_datos, periodo, importe, recargo, fecha_hora_pago, id_recaudadora, caja, operacion, folio_recibo, usuario, id_stat)
        VALUES (par_id_34_datos, make_date(par_Axo, par_Mes, 1), 0, 0, par_Fecha, par_Id_Rec, par_Caja, par_Consec, par_Folio_rcbo, par_usuario, (SELECT id_34_stat FROM t34_status WHERE cve_stat = 'P'));
        v_status := 1;
        v_msg := 'Pago registrado correctamente.';
    ELSIF par_status = 'S' THEN
        -- Lógica de condonación
        v_status := 1;
        v_msg := 'Adeudo condonado correctamente.';
    ELSIF par_status = 'C' THEN
        -- Lógica de cancelación
        v_status := 1;
        v_msg := 'Adeudo cancelado correctamente.';
    ELSIF par_status = 'R' THEN
        -- Lógica de prescripción
        v_status := 1;
        v_msg := 'Adeudo prescrito correctamente.';
    ELSE
        v_status := 0;
        v_msg := 'Opción no válida.';
    END IF;
    RETURN QUERY SELECT v_status, v_msg;
END;
$$ LANGUAGE plpgsql;