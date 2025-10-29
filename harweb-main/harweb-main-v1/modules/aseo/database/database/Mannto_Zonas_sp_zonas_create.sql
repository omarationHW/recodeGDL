-- Stored Procedure: sp_zonas_create
-- Tipo: Catalog
-- Descripción: Crea una nueva zona si no existe la combinación zona/sub_zona.
-- Generado para formulario: Mannto_Zonas
-- Fecha: 2025-08-27 14:55:29

CREATE OR REPLACE FUNCTION sp_zonas_create(p_zona smallint, p_sub_zona smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text, ctrol_zona integer) AS $$
DECLARE
  v_exists integer;
  v_ctrol integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe la zona/sub-zona', NULL;
    RETURN;
  END IF;
  INSERT INTO ta_16_zonas (ctrol_zona, zona, sub_zona, descripcion)
    VALUES (DEFAULT, p_zona, p_sub_zona, p_descripcion)
    RETURNING ctrol_zona INTO v_ctrol;
  RETURN QUERY SELECT true, 'Zona creada correctamente', v_ctrol;
END;
$$ LANGUAGE plpgsql;