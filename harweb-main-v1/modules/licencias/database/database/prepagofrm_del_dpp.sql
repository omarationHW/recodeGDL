-- Stored Procedure: del_dpp
-- Tipo: CRUD
-- Descripción: Elimina el descuento de pronto pago para una cuenta catastral.
-- Generado para formulario: prepagofrm
-- Fecha: 2025-08-26 17:25:48

CREATE OR REPLACE PROCEDURE del_dpp(IN p_cvecuenta INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE detsaldos SET cvedescuento = NULL WHERE cvecuenta = p_cvecuenta AND cvedescuento = 999999;
END;
$$;