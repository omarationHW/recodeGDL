-- Stored Procedure: upd34_ade_01
-- Tipo: CRUD
-- Descripción: Actualiza el status de un adeudo (pagado, condonado, cancelado, prescrito)
-- Generado para formulario: RAdeudos_OpcMult
-- Fecha: 2025-08-28 13:32:20

CREATE OR REPLACE FUNCTION upd34_ade_01(
  par_id_datos integer,
  par_Axo integer,
  par_Mes integer,
  par_Fecha date,
  par_Id_Rec integer,
  par_Caja varchar,
  par_Consec integer,
  par_Folio_rcbo varchar,
  par_tab varchar,
  par_status varchar,
  par_Opc varchar
) RETURNS TABLE(status integer, concepto_status varchar) AS $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count FROM t34_adeudos WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  IF v_count = 0 THEN
    RETURN QUERY SELECT 1, 'Adeudo no encontrado';
    RETURN;
  END IF;
  UPDATE t34_adeudos
    SET status = par_status,
        fecha_pago = par_Fecha,
        id_recaudadora = par_Id_Rec,
        caja = par_Caja,
        operacion = par_Consec,
        folio_recibo = par_Folio_rcbo
    WHERE id_adeudo = par_id_datos AND axo = par_Axo AND mes = par_Mes;
  RETURN QUERY SELECT 0, 'Actualización exitosa';
END;
$$ LANGUAGE plpgsql;