-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Zonas
-- Generado: 2025-08-27 14:55:29
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_zonas_create
-- Tipo: Catalog
-- Descripción: Crea una nueva zona si no existe la combinación zona/sub_zona.
-- --------------------------------------------

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

-- ============================================

-- SP 2/3: sp_zonas_update
-- Tipo: Catalog
-- Descripción: Actualiza la descripción de una zona existente.
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: sp_zonas_delete
-- Tipo: Catalog
-- Descripción: Elimina una zona si no tiene empresas dependientes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_delete(p_ctrol_zona integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_emp integer;
BEGIN
  SELECT COUNT(*) INTO v_emp FROM ta_16_empresas WHERE ctrol_zona = p_ctrol_zona;
  IF v_emp > 0 THEN
    RETURN QUERY SELECT false, 'Existen empresas con esta zona. No se puede borrar.';
    RETURN;
  END IF;
  DELETE FROM ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
  RETURN QUERY SELECT true, 'Zona eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

