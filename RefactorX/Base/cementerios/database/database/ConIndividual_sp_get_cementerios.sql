-- Stored Procedure: sp_get_cementerios
-- Tipo: Catalog
-- Descripción: Obtiene datos de cementerio por clave
-- Generado para formulario: ConIndividual
-- Fecha: 2025-08-28 17:50:28

CREATE OR REPLACE PROCEDURE sp_get_cementerios(IN cementerio text)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT * FROM tc_13_cementerios WHERE cementerio = cementerio;
END;
$$;