-- Stored Procedure: sp_upd34_gen_adeudos_ind
-- Tipo: CRUD
-- Descripción: Procesa la opción múltiple de adeudos (pago, condonación, cancelación, prescripción) para un registro y periodo.
-- Generado para formulario: GAdeudos_OpcMult
-- Fecha: 2025-08-27 20:44:01

CREATE OR REPLACE FUNCTION sp_upd34_gen_adeudos_ind(
    par_id_34_datos integer,
    par_Axo integer,
    par_Mes integer,
    par_Fecha date,
    par_Id_Rec integer,
    par_Caja text,
    par_Consec integer,
    par_Folio_rcbo text,
    par_tab text,
    par_status text,
    par_Opc text,
    par_usuario text
) RETURNS TABLE(status integer, concepto_status text) AS $$
DECLARE
    v_exists integer;
BEGIN
    -- Validar existencia
    SELECT COUNT(*) INTO v_exists FROM t34_conceptos WHERE id_datos = par_id_34_datos AND axo = par_Axo AND mes = par_Mes;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 0, 'No existen Adeudos Seleccionados';
        RETURN;
    END IF;
    -- Actualizar status según opción
    UPDATE t34_conceptos
    SET status = par_status, fecha_pago = par_Fecha, id_recaudadora = par_Id_Rec, caja = par_Caja, operacion = par_Consec, folio_recibo = par_Folio_rcbo, usuario = par_usuario
    WHERE id_datos = par_id_34_datos AND axo = par_Axo AND mes = par_Mes;
    RETURN QUERY SELECT 1, 'Proceso realizado correctamente';
END;
$$ LANGUAGE plpgsql;