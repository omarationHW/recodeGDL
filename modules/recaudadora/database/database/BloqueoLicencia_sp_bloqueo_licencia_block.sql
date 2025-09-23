-- Stored Procedure: sp_bloqueo_licencia_block
-- Tipo: CRUD
-- Descripción: Bloquea una licencia para requerir
-- Generado para formulario: BloqueoLicencia
-- Fecha: 2025-08-26 22:41:15

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