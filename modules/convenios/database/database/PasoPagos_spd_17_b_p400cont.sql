-- Stored Procedure: spd_17_b_p400cont
-- Tipo: CRUD
-- Descripción: Limpia la tabla temporal de paso de pagos de contratos AS/400
-- Generado para formulario: PasoPagos
-- Fecha: 2025-08-27 15:14:09

CREATE OR REPLACE PROCEDURE spd_17_b_p400cont()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE ta_17_paso_p_400 RESTART IDENTITY;
END;
$$;