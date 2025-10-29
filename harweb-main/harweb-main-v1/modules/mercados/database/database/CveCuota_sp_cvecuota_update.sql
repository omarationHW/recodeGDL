-- Stored Procedure: sp_cvecuota_update
-- Tipo: CRUD
-- Descripción: Actualiza una clave de cuota existente.
-- Generado para formulario: CveCuota
-- Fecha: 2025-08-26 23:37:19

CREATE OR REPLACE FUNCTION sp_cvecuota_update(p_clave_cuota smallint, p_descripcion varchar)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_cve_cuota
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE clave_cuota = p_clave_cuota;
END;$$;