-- Stored Procedure: sp_get_datosrcmadic
-- Tipo: Catalog
-- Descripción: Obtiene datos adicionales de RCM
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_datosrcmadic(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_13_datosrcmadic WHERE control_rcm = control_rcm;
END;
$$;