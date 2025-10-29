-- Stored Procedure: sp_get_datosrcm
-- Tipo: Catalog
-- Descripción: Obtiene los datos principales de un registro RCM por folio
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_datosrcm(IN fol integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_13_datosrcm WHERE control_rcm = fol;
END;
$$;