-- Stored Procedure: sp_bloqueo_licencia_history
-- Tipo: Report
-- Descripción: Historial de bloqueos/desbloqueos de una licencia
-- Generado para formulario: BloqueoLicencia
-- Fecha: 2025-08-26 22:41:15

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