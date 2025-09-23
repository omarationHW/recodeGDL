-- Stored Procedure: calc_dpp
-- Tipo: CRUD
-- Descripción: Calcula y aplica el descuento de pronto pago para una cuenta catastral.
-- Generado para formulario: prepagofrm
-- Fecha: 2025-08-26 17:25:48

CREATE OR REPLACE PROCEDURE calc_dpp(IN p_cvecuenta INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Lógica de cálculo de pronto pago (simplificada)
  UPDATE detsaldos SET cvedescuento = 999999 WHERE cvecuenta = p_cvecuenta AND saldo > 0 AND axosal = EXTRACT(YEAR FROM CURRENT_DATE) AND bimsal = 6;
END;
$$;