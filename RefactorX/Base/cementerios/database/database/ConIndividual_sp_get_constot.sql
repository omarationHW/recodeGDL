-- Stored Procedure: sp_get_constot
-- Tipo: Report
-- Descripción: Obtiene totales de cajero por control y año
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_constot(IN par_control integer, IN par_axo integer)
LANGUAGE plpgsql
AS $$
BEGIN
  -- Aquí debe ir la lógica de totales de cajero, ejemplo:
  SELECT slinea, sclave, stotal, sctaapli, sobserv
  FROM spd_13_constot(par_control, par_axo);
END;
$$;