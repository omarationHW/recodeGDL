-- Stored Procedure: sp_bloqueo_licencia_unblock
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia para requerir
-- Generado para formulario: BloqueoLicencia
-- Fecha: 2025-08-26 22:41:15

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