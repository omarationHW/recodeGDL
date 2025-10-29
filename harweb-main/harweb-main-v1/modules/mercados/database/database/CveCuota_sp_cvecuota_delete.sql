-- Stored Procedure: sp_cvecuota_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de cuota.
-- Generado para formulario: CveCuota
-- Fecha: 2025-08-26 23:37:19

CREATE OR REPLACE FUNCTION sp_cvecuota_delete(p_clave_cuota smallint)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  DELETE FROM ta_11_cve_cuota WHERE clave_cuota = p_clave_cuota;
END;$$;