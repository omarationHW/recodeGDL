-- Stored Procedure: sp_bloqueo_licencia_update
-- Tipo: CRUD
-- Descripción: Actualiza la fecha de bloqueo y motivo
-- Generado para formulario: BloqueoLicencia
-- Fecha: 2025-08-26 22:41:15

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