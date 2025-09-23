-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: BloqueoLicencia
-- Generado: 2025-08-26 22:41:15
-- Total SPs: 7
-- ============================================

-- SP 1/7: sp_bloqueo_licencia_search
-- Tipo: CRUD
-- Descripción: Busca una licencia y su estado de bloqueo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_search(p_licencia INTEGER)
RETURNS TABLE(
  id_licencia INTEGER,
  licencia INTEGER,
  propietario TEXT,
  domicilio TEXT,
  bloqueada BOOLEAN,
  motivo TEXT,
  feccap DATE,
  fecbaja DATE,
  capturista TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.id_licencia, l.licencia, l.propietario, l.ubicacion AS domicilio,
      CASE WHEN n.id_control IS NOT NULL AND n.fecbaja IS NULL THEN TRUE ELSE FALSE END AS bloqueada,
      n.observacion, n.feccap, n.fecbaja, n.capturista
    FROM licencias l
    LEFT JOIN norequeriblelic n ON n.id_licencia = l.id_licencia AND n.fecbaja IS NULL
    WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp_bloqueo_licencia_block
-- Tipo: CRUD
-- Descripción: Bloquea una licencia para requerir
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_block(
  p_licencia INTEGER,
  p_motivo TEXT,
  p_fecha_bloqueo DATE,
  p_usuario TEXT
) RETURNS TABLE(result TEXT) AS $$
DECLARE
  v_id_licencia INTEGER;
BEGIN
  SELECT id_licencia INTO v_id_licencia FROM licencias WHERE licencia = p_licencia;
  IF v_id_licencia IS NULL THEN
    RETURN QUERY SELECT 'Licencia no encontrada';
    RETURN;
  END IF;
  -- Verifica si ya está bloqueada
  IF EXISTS (SELECT 1 FROM norequeriblelic WHERE id_licencia = v_id_licencia AND fecbaja IS NULL) THEN
    RETURN QUERY SELECT 'La licencia ya está bloqueada';
    RETURN;
  END IF;
  INSERT INTO norequeriblelic (id_licencia, feccap, capturista, observacion, tipo_bloq)
    VALUES (v_id_licencia, p_fecha_bloqueo, p_usuario, p_motivo, 1);
  RETURN QUERY SELECT 'Licencia bloqueada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: sp_bloqueo_licencia_unblock
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia para requerir
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_unblock(
  p_licencia INTEGER,
  p_motivo TEXT,
  p_fecha_desbloqueo DATE,
  p_usuario TEXT
) RETURNS TABLE(result TEXT) AS $$
DECLARE
  v_id_licencia INTEGER;
BEGIN
  SELECT id_licencia INTO v_id_licencia FROM licencias WHERE licencia = p_licencia;
  IF v_id_licencia IS NULL THEN
    RETURN QUERY SELECT 'Licencia no encontrada';
    RETURN;
  END IF;
  UPDATE norequeriblelic
    SET fecbaja = p_fecha_desbloqueo, user_baja = p_usuario, observacion = COALESCE(observacion, '') || '\n' || p_motivo
    WHERE id_licencia = v_id_licencia AND fecbaja IS NULL;
  RETURN QUERY SELECT 'Licencia desbloqueada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp_bloqueo_licencia_list
-- Tipo: Report
-- Descripción: Lista licencias bloqueadas o desbloqueadas por fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_list(p_status TEXT, p_fecha DATE)
RETURNS TABLE(
  id_control INTEGER,
  id_licencia INTEGER,
  feccap DATE,
  capturista TEXT,
  fecbaja DATE,
  user_baja TEXT,
  observacion TEXT,
  tipo_bloq INTEGER,
  licencia INTEGER,
  propietario TEXT
) AS $$
BEGIN
  IF p_status = 'blocked' THEN
    RETURN QUERY
      SELECT n.id_control, n.id_licencia, n.feccap, n.capturista, n.fecbaja, n.user_baja, n.observacion, n.tipo_bloq, l.licencia, l.propietario
      FROM norequeriblelic n
      JOIN licencias l ON l.id_licencia = n.id_licencia
      WHERE n.fecbaja IS NULL AND (p_fecha IS NULL OR n.feccap = p_fecha);
  ELSE
    RETURN QUERY
      SELECT n.id_control, n.id_licencia, n.feccap, n.capturista, n.fecbaja, n.user_baja, n.observacion, n.tipo_bloq, l.licencia, l.propietario
      FROM norequeriblelic n
      JOIN licencias l ON l.id_licencia = n.id_licencia
      WHERE n.fecbaja IS NOT NULL AND (p_fecha IS NULL OR n.fecbaja = p_fecha);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp_bloqueo_licencia_history
-- Tipo: Report
-- Descripción: Historial de bloqueos/desbloqueos de una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_history(p_licencia INTEGER)
RETURNS TABLE(
  id_control INTEGER,
  id_licencia INTEGER,
  feccap DATE,
  capturista TEXT,
  fecbaja DATE,
  user_baja TEXT,
  observacion TEXT,
  tipo_bloq INTEGER
) AS $$
DECLARE
  v_id_licencia INTEGER;
BEGIN
  SELECT id_licencia INTO v_id_licencia FROM licencias WHERE licencia = p_licencia;
  IF v_id_licencia IS NULL THEN
    RETURN;
  END IF;
  RETURN QUERY
    SELECT id_control, id_licencia, feccap, capturista, fecbaja, user_baja, observacion, tipo_bloq
    FROM norequeriblelic
    WHERE id_licencia = v_id_licencia
    ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp_bloqueo_licencia_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de bloqueo y motivo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_update(
  p_licencia INTEGER,
  p_fecha_bloqueo DATE,
  p_motivo TEXT,
  p_usuario TEXT
) RETURNS TABLE(result TEXT) AS $$
DECLARE
  v_id_licencia INTEGER;
BEGIN
  SELECT id_licencia INTO v_id_licencia FROM licencias WHERE licencia = p_licencia;
  IF v_id_licencia IS NULL THEN
    RETURN QUERY SELECT 'Licencia no encontrada';
    RETURN;
  END IF;
  UPDATE norequeriblelic
    SET feccap = p_fecha_bloqueo, observacion = COALESCE(observacion, '') || '\n' || p_motivo, capturista = p_usuario
    WHERE id_licencia = v_id_licencia AND fecbaja IS NULL;
  RETURN QUERY SELECT 'Fecha de bloqueo actualizada';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: sp_bloqueo_licencia_report
-- Tipo: Report
-- Descripción: Reporte de bloqueos/desbloqueos por tipo y fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_bloqueo_licencia_report(p_tipo TEXT, p_fecha DATE)
RETURNS TABLE(
  id_control INTEGER,
  id_licencia INTEGER,
  feccap DATE,
  capturista TEXT,
  fecbaja DATE,
  user_baja TEXT,
  observacion TEXT,
  tipo_bloq INTEGER,
  licencia INTEGER,
  propietario TEXT
) AS $$
BEGIN
  IF p_tipo = 'blocked' THEN
    RETURN QUERY
      SELECT n.id_control, n.id_licencia, n.feccap, n.capturista, n.fecbaja, n.user_baja, n.observacion, n.tipo_bloq, l.licencia, l.propietario
      FROM norequeriblelic n
      JOIN licencias l ON l.id_licencia = n.id_licencia
      WHERE n.fecbaja IS NULL AND (p_fecha IS NULL OR n.feccap = p_fecha);
  ELSE
    RETURN QUERY
      SELECT n.id_control, n.id_licencia, n.feccap, n.capturista, n.fecbaja, n.user_baja, n.observacion, n.tipo_bloq, l.licencia, l.propietario
      FROM norequeriblelic n
      JOIN licencias l ON l.id_licencia = n.id_licencia
      WHERE n.fecbaja IS NOT NULL AND (p_fecha IS NULL OR n.fecbaja = p_fecha);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

