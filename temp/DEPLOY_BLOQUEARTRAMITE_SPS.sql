-- =====================================================
-- STORED PROCEDURES - BloquearTramitefrm.vue
-- Módulo: Padrón de Licencias
-- Funcionalidad: Bloqueo/Desbloqueo de Trámites
-- Base de Datos: padron_licencias (192.168.6.146)
-- Esquema: comun
-- Usuario: refact
-- Fecha: 2025-11-08
-- SPs: 5
-- =====================================================

-- SP 1/5: sp_bloqueartramite_get_tramite
-- Obtiene la información completa de un trámite por ID

DROP FUNCTION IF EXISTS comun.sp_bloqueartramite_get_tramite(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_bloqueartramite_get_tramite(p_id_tramite INTEGER)
RETURNS TABLE(
  id_tramite INTEGER,
  licencia INTEGER,
  tipo_tramite VARCHAR,
  giro INTEGER,
  fecha DATE,
  estatus VARCHAR,
  solicitante TEXT,
  rfc VARCHAR,
  domicilio VARCHAR,
  usuario_captura VARCHAR,
  observaciones TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.id_tramite,
    t.licencia_ref AS licencia,
    CASE t.tipo_tramite
      WHEN 'N' THEN 'Nueva Licencia'
      WHEN 'M' THEN 'Modificación'
      WHEN 'R' THEN 'Refrendo'
      WHEN 'B' THEN 'Baja'
      WHEN 'A' THEN 'Anuncio'
      ELSE 'Otro'
    END::VARCHAR AS tipo_tramite,
    t.id_giro AS giro,
    t.feccap AS fecha,
    t.estatus::VARCHAR,
    TRIM(COALESCE(t.propietario, '') || ' ' || COALESCE(t.primer_ap, '') || ' ' || COALESCE(t.segundo_ap, ''))::TEXT AS solicitante,
    t.rfc::VARCHAR,
    t.domicilio::VARCHAR,
    t.capturista::VARCHAR AS usuario_captura,
    t.observaciones::TEXT
  FROM comun.tramites t
  WHERE t.id_tramite = p_id_tramite;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 2/5: sp_bloqueartramite_get_bloqueos
-- Obtiene el historial de bloqueos de un trámite

DROP FUNCTION IF EXISTS comun.sp_bloqueartramite_get_bloqueos(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_bloqueartramite_get_bloqueos(p_id_tramite INTEGER)
RETURNS TABLE(
  id_bloqueo INTEGER,
  id_tramite INTEGER,
  tipo VARCHAR,
  motivo_bloqueo TEXT,
  fecha_bloqueo TIMESTAMP,
  usuario_bloqueo VARCHAR,
  motivo_desbloqueo TEXT,
  fecha_desbloqueo TIMESTAMP,
  usuario_desbloqueo VARCHAR,
  activo BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    b.id_bloqueo,
    b.id_tramite,
    b.tipo::VARCHAR,
    b.motivo_bloqueo,
    b.fecha_bloqueo,
    b.usuario_bloqueo::VARCHAR,
    b.motivo_desbloqueo,
    b.fecha_desbloqueo,
    b.usuario_desbloqueo::VARCHAR,
    b.activo
  FROM comun.bloqueos_tramites b
  WHERE b.id_tramite = p_id_tramite
  ORDER BY b.fecha_bloqueo DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 3/5: sp_bloqueartramite_get_giro
-- Obtiene la descripción de un giro

DROP FUNCTION IF EXISTS comun.sp_bloqueartramite_get_giro(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_bloqueartramite_get_giro(p_giro INTEGER)
RETURNS TABLE(
  giro INTEGER,
  descripcion VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    g.giro::INTEGER,
    g.descripcion::VARCHAR
  FROM comun.liccat_giros g
  WHERE g.giro = p_giro
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 4/5: sp_bloqueartramite_bloquear
-- Registra un nuevo bloqueo de trámite

DROP FUNCTION IF EXISTS comun.sp_bloqueartramite_bloquear(INTEGER, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION comun.sp_bloqueartramite_bloquear(
  p_id_tramite INTEGER,
  p_tipo TEXT,
  p_motivo TEXT,
  p_usuario TEXT
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT,
  id_bloqueo INTEGER
) AS $$
DECLARE
  v_tramite_existe BOOLEAN;
  v_bloqueo_activo BOOLEAN;
  v_new_id INTEGER;
BEGIN
  SELECT EXISTS(SELECT 1 FROM comun.tramites WHERE id_tramite = p_id_tramite) INTO v_tramite_existe;

  IF NOT v_tramite_existe THEN
    RETURN QUERY SELECT FALSE, 'El trámite no existe'::TEXT, NULL::INTEGER;
    RETURN;
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM comun.bloqueos_tramites
    WHERE id_tramite = p_id_tramite AND activo = TRUE
  ) INTO v_bloqueo_activo;

  IF v_bloqueo_activo THEN
    RETURN QUERY SELECT FALSE, 'El trámite ya tiene un bloqueo activo'::TEXT, NULL::INTEGER;
    RETURN;
  END IF;

  INSERT INTO comun.bloqueos_tramites (
    id_tramite,
    tipo,
    motivo_bloqueo,
    usuario_bloqueo,
    activo
  )
  VALUES (
    p_id_tramite,
    p_tipo,
    p_motivo,
    p_usuario,
    TRUE
  )
  RETURNING id_bloqueo INTO v_new_id;

  UPDATE comun.tramites SET bloqueado = 1 WHERE id_tramite = p_id_tramite;

  RETURN QUERY SELECT TRUE, 'Trámite bloqueado exitosamente'::TEXT, v_new_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================

-- SP 5/5: sp_bloqueartramite_desbloquear
-- Desbloquea un trámite (actualiza el bloqueo como inactivo)

DROP FUNCTION IF EXISTS comun.sp_bloqueartramite_desbloquear(INTEGER, TEXT, TEXT);

CREATE OR REPLACE FUNCTION comun.sp_bloqueartramite_desbloquear(
  p_id_bloqueo INTEGER,
  p_motivo_desbloqueo TEXT,
  p_usuario TEXT
)
RETURNS TABLE(
  success BOOLEAN,
  message TEXT
) AS $$
DECLARE
  v_id_tramite INTEGER;
  v_activo BOOLEAN;
BEGIN
  SELECT id_tramite, activo
  INTO v_id_tramite, v_activo
  FROM comun.bloqueos_tramites
  WHERE id_bloqueo = p_id_bloqueo;

  IF v_id_tramite IS NULL THEN
    RETURN QUERY SELECT FALSE, 'El bloqueo no existe'::TEXT;
    RETURN;
  END IF;

  IF v_activo = FALSE THEN
    RETURN QUERY SELECT FALSE, 'El bloqueo ya está inactivo'::TEXT;
    RETURN;
  END IF;

  UPDATE comun.bloqueos_tramites
  SET
    activo = FALSE,
    motivo_desbloqueo = p_motivo_desbloqueo,
    fecha_desbloqueo = NOW(),
    usuario_desbloqueo = p_usuario
  WHERE id_bloqueo = p_id_bloqueo;

  IF NOT EXISTS(
    SELECT 1 FROM comun.bloqueos_tramites
    WHERE id_tramite = v_id_tramite AND activo = TRUE
  ) THEN
    UPDATE comun.tramites SET bloqueado = 0 WHERE id_tramite = v_id_tramite;
  END IF;

  RETURN QUERY SELECT TRUE, 'Trámite desbloqueado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON FUNCTION comun.sp_bloqueartramite_get_tramite(INTEGER) IS
'Obtiene la información completa de un trámite por ID';

COMMENT ON FUNCTION comun.sp_bloqueartramite_get_bloqueos(INTEGER) IS
'Obtiene el historial de bloqueos de un trámite';

COMMENT ON FUNCTION comun.sp_bloqueartramite_get_giro(INTEGER) IS
'Obtiene la descripción de un giro';

COMMENT ON FUNCTION comun.sp_bloqueartramite_bloquear(INTEGER, TEXT, TEXT, TEXT) IS
'Registra un nuevo bloqueo de trámite';

COMMENT ON FUNCTION comun.sp_bloqueartramite_desbloquear(INTEGER, TEXT, TEXT) IS
'Desbloquea un trámite (actualiza el bloqueo como inactivo)';

-- =====================================================
-- PERMISOS
-- =====================================================

GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_get_tramite(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_get_tramite(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_get_bloqueos(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_get_bloqueos(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_get_giro(INTEGER) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_get_giro(INTEGER) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_bloquear(INTEGER, TEXT, TEXT, TEXT) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_bloquear(INTEGER, TEXT, TEXT, TEXT) TO PUBLIC;

GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_desbloquear(INTEGER, TEXT, TEXT) TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_bloqueartramite_desbloquear(INTEGER, TEXT, TEXT) TO PUBLIC;
