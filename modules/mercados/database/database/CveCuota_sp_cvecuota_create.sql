-- Stored Procedure: sp_cvecuota_create
-- Tipo: CRUD
-- Descripción: Crea una nueva clave de cuota.
-- Generado para formulario: CveCuota
-- Fecha: 2025-08-26 23:37:19

CREATE OR REPLACE FUNCTION sp_cvecuota_create(p_clave_cuota smallint, p_descripcion varchar)
RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_cve_cuota (clave_cuota, descripcion)
  VALUES (p_clave_cuota, UPPER(TRIM(p_descripcion)));
END;$$;