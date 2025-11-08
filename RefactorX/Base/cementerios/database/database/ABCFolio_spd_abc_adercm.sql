-- Stored Procedure: spd_abc_adercm
-- Tipo: CRUD
-- Descripción: Recalcula adeudos de un folio según la operación (1=alta, 2=baja, 3=modificación)
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-28 17:27:19

CREATE OR REPLACE PROCEDURE spd_abc_adercm(IN par_control INTEGER, IN par_opc INTEGER, IN par_usu INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  IF par_opc = 1 THEN
    -- Alta: genera adeudos para nueva fosa
    INSERT INTO ta_13_adeudosrcm (control_rcm, axo_adeudo, importe, importe_recargos, descto_impote, descto_recargos, actualizacion, vigencia, usuario, fecha_mov)
    SELECT par_control, y, 0, 0, 0, 0, 0, 'V', par_usu, now()
    FROM generate_series(EXTRACT(YEAR FROM now())-6, EXTRACT(YEAR FROM now())::int) AS y;
  ELSIF par_opc = 2 THEN
    -- Baja: marca adeudos como baja
    UPDATE ta_13_adeudosrcm SET vigencia = 'B', usuario = par_usu, fecha_mov = now() WHERE control_rcm = par_control;
  ELSIF par_opc = 3 THEN
    -- Modificación: recalcula adeudos si es necesario (ejemplo: si axo_pagado cambió)
    -- Aquí se puede agregar lógica específica según reglas de negocio
    UPDATE ta_13_adeudosrcm SET usuario = par_usu, fecha_mov = now() WHERE control_rcm = par_control;
  END IF;
END;
$$;