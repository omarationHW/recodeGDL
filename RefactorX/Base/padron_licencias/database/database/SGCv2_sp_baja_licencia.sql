-- Stored Procedure: sp_baja_licencia
-- Tipo: CRUD
-- Descripción: Da de baja una licencia y sus anuncios ligados
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_baja_licencia(p_licencia INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE licencias SET vigente = 'C', fecha_baja = NOW(), espubic = p_motivo WHERE licencia = p_licencia;
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW() WHERE id_licencia = (SELECT id_licencia FROM licencias WHERE licencia = p_licencia);
    v_result := json_build_object('licencia', p_licencia, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;