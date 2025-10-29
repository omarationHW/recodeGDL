-- Stored Procedure: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia con un tipo de bloqueo y motivo.
-- Generado para formulario: consultaLicenciafrm
-- Fecha: 2025-08-27 17:25:29

CREATE OR REPLACE FUNCTION sp_bloquear_licencia(p_id_licencia integer, p_tipo_bloqueo integer, p_motivo varchar)
RETURNS void AS $$
BEGIN
  UPDATE licencias SET bloqueado = p_tipo_bloqueo WHERE id_licencia = p_id_licencia;
  INSERT INTO bloqueo (bloqueado, id_licencia, observa, vigente, fecha_mov, capturista)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, 'V', now(), current_user);
END;
$$ LANGUAGE plpgsql;