-- Stored Procedure: sp_13_historia
-- Tipo: CRUD
-- Descripción: Guarda un registro histórico de la modificación de un folio
-- Generado para formulario: ABCFolio
-- Fecha: 2025-08-28 17:27:19

CREATE OR REPLACE PROCEDURE sp_13_historia(IN par_control INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO ta_13_datosrcm_historico (
    control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia, fecha_his
  )
  SELECT control_rcm, cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa, fosa, fosa_alfa, axo_pagado, metros, nombre, domicilio, exterior, interior, colonia, observaciones, usuario, fecha_mov, tipo, fecha_alta, vigencia, now()
  FROM ta_13_datosrcm WHERE control_rcm = par_control;
END;
$$;