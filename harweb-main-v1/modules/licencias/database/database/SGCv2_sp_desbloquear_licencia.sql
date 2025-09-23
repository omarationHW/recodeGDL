-- Stored Procedure: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia por motivo y usuario
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_desbloquear_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET bloqueado = 0 WHERE licencia = p_licencia;
    INSERT INTO bloqueo (id_licencia, bloqueado, observacion, capturista, fecha_mov, vigente)
    VALUES (p_licencia, 0, p_motivo, p_usuario, NOW(), 'V');
    v_result := json_build_object('licencia', p_licencia, 'status', 'desbloqueada');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;