-- Stored Procedure: sp_get_bonifrcm
-- Tipo: Catalog
-- Descripción: Obtiene suma de bonificaciones para un control_rcm
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_bonifrcm(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT COALESCE(SUM(importe_resto),0) AS bonifica FROM ta_13_bonifrcm WHERE control_rcm = control_rcm AND importe_resto > 0;
END;
$$;