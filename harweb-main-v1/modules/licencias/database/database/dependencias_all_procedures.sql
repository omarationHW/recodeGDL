-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: dependenciasFrm
-- Generado: 2025-08-27 17:32:45
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_dependencias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de dependencias activas para licencias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dependencias()
RETURNS TABLE(id_dependencia INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_dependencia, descripcion
    FROM c_dependencias
    WHERE licencias = 1 AND vigente = 'V'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_tramite_inspecciones
-- Tipo: Report
-- Descripción: Obtiene las inspecciones/revisiones actuales de un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tramite_inspecciones(p_id_tramite INT)
RETURNS TABLE(id_revision INT, id_dependencia INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT r.id_revision, r.id_dependencia, d.descripcion
    FROM revisiones r
    INNER JOIN c_dependencias d ON r.id_dependencia = d.id_dependencia
    WHERE r.id_tramite = p_id_tramite AND r.estatus = 'V'
    ORDER BY d.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_add_inspeccion
-- Tipo: CRUD
-- Descripción: Agrega una inspección/revisión a un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_inspeccion(p_id_tramite INT, p_id_dependencia INT, p_usuario TEXT)
RETURNS TEXT AS $$
DECLARE
  v_exists INT;
  v_id_revision INT;
  v_desc TEXT;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM revisiones WHERE id_tramite = p_id_tramite AND id_dependencia = p_id_dependencia AND estatus = 'V';
  IF v_exists > 0 THEN
    RETURN 'Ya existe esta inspección para el trámite';
  END IF;
  SELECT descripcion INTO v_desc FROM c_dependencias WHERE id_dependencia = p_id_dependencia;
  INSERT INTO revisiones (id_tramite, id_dependencia, fecha_inicio, estatus, descripcion)
    VALUES (p_id_tramite, p_id_dependencia, NOW(), 'V', v_desc)
    RETURNING id_revision INTO v_id_revision;
  INSERT INTO seg_revision (id_revision, estatus, feccap, usr_revisa)
    VALUES (v_id_revision, 'V', NOW(), p_usuario);
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_delete_inspeccion
-- Tipo: CRUD
-- Descripción: Elimina una inspección/revisión de un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_inspeccion(p_id_tramite INT, p_id_dependencia INT)
RETURNS TEXT AS $$
DECLARE
  v_id_revision INT;
BEGIN
  SELECT id_revision INTO v_id_revision FROM revisiones WHERE id_tramite = p_id_tramite AND id_dependencia = p_id_dependencia AND estatus = 'V' LIMIT 1;
  IF v_id_revision IS NULL THEN
    RETURN 'No existe la inspección para eliminar';
  END IF;
  DELETE FROM seg_revision WHERE id_revision = v_id_revision;
  DELETE FROM revisiones WHERE id_revision = v_id_revision;
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_get_tramite_info
-- Tipo: Report
-- Descripción: Obtiene información básica de un trámite
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tramite_info(p_id_tramite INT)
RETURNS TABLE(id_tramite INT, propietario TEXT, ubicacion TEXT, estatus TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_tramite, propietario, ubicacion, estatus FROM tramites WHERE id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- ============================================

