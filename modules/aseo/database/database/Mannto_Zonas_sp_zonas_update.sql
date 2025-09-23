-- Stored Procedure: sp_zonas_update
-- Tipo: Catalog
-- Descripción: Actualiza la descripción de una zona existente.
-- Generado para formulario: Mannto_Zonas
-- Fecha: 2025-08-27 14:55:29

CREATE OR REPLACE FUNCTION sp_zonas_update(p_zona smallint, p_sub_zona smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT false, 'No existe la zona/sub-zona', NULL;
    RETURN;
  END IF;
  UPDATE ta_16_zonas SET descripcion = p_descripcion WHERE zona = p_zona AND sub_zona = p_sub_zona;
  RETURN QUERY SELECT true, 'Zona actualizada correctamente';
END;
$$ LANGUAGE plpgsql;