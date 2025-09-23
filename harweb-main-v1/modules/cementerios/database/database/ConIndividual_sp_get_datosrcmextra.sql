-- Stored Procedure: sp_get_datosrcmextra
-- Tipo: Catalog
-- Descripción: Obtiene personas que pagan por el RCM
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_datosrcmextra(IN control_rcm integer)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM ta_13_datosrcmextra WHERE control_rcm = control_rcm;
END;
$$;