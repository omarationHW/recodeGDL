-- Stored Procedure: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia para un tipo de bloqueo específico.
-- Generado para formulario: consultaLicenciafrm
-- Fecha: 2025-08-27 17:25:29

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(p_id_licencia integer, p_tipo_bloqueo integer, p_motivo varchar)
RETURNS void AS $$
BEGIN
  UPDATE bloqueo SET vigente = 'C' WHERE id_licencia = p_id_licencia AND bloqueado = p_tipo_bloqueo AND vigente = 'V';
  UPDATE licencias SET bloqueado = 0 WHERE id_licencia = p_id_licencia;
  INSERT INTO bloqueo (bloqueado, id_licencia, observa, vigente, fecha_mov, capturista)
    VALUES (0, p_id_licencia, p_motivo, 'V', now(), current_user);
END;
$$ LANGUAGE plpgsql;