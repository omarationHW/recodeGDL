-- Stored Procedure: sp_bloqueo_licencia_list
-- Tipo: Report
-- Descripción: Lista licencias bloqueadas o desbloqueadas por fecha
-- Generado para formulario: BloqueoLicencia
-- Fecha: 2025-08-26 22:41:15

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