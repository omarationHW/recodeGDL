-- Stored Procedure: sp_cvecuota_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de cuota.
-- Generado para formulario: CveCuota
-- Fecha: 2025-08-26 23:37:19

CREATE OR REPLACE FUNCTION sp_cvecuota_list()
RETURNS TABLE(clave_cuota smallint, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota ORDER BY clave_cuota ASC;
END;$$;