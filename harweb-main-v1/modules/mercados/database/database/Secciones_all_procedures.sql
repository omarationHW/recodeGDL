-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Secciones
-- Generado: 2025-08-27 01:30:23
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_secciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las secciones ordenadas por clave.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_secciones_list()
RETURNS TABLE(seccion VARCHAR(2), descripcion VARCHAR(30)) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM ta_11_secciones ORDER BY seccion ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_secciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva sección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_secciones_create(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
    RETURN QUERY SELECT FALSE, 'La sección ya existe.';
    RETURN;
  END IF;
  INSERT INTO ta_11_secciones(seccion, descripcion) VALUES (UPPER(p_seccion), UPPER(p_descripcion));
  RETURN QUERY SELECT TRUE, 'Sección creada correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_secciones_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una sección existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_secciones_update(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
    RETURN QUERY SELECT FALSE, 'La sección no existe.';
    RETURN;
  END IF;
  UPDATE ta_11_secciones SET descripcion = UPPER(p_descripcion) WHERE seccion = p_seccion;
  RETURN QUERY SELECT TRUE, 'Sección actualizada correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_secciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una sección por clave.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_secciones_delete(p_seccion VARCHAR(2))
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ta_11_secciones WHERE seccion = p_seccion) THEN
    RETURN QUERY SELECT FALSE, 'La sección no existe.';
    RETURN;
  END IF;
  DELETE FROM ta_11_secciones WHERE seccion = p_seccion;
  RETURN QUERY SELECT TRUE, 'Sección eliminada correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

