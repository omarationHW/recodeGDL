-- Stored Procedure: sp_cvecuota_get
-- Tipo: Catalog
-- Descripción: Obtiene una clave de cuota específica.
-- Generado para formulario: CveCuota
-- Fecha: 2025-08-26 23:37:19

CREATE OR REPLACE FUNCTION sp_cvecuota_get(p_clave_cuota smallint)
RETURNS TABLE(clave_cuota smallint, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT clave_cuota, descripcion FROM ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
END;$$;