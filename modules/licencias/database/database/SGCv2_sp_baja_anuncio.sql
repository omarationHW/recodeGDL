-- Stored Procedure: sp_baja_anuncio
-- Tipo: CRUD
-- Descripción: Da de baja un anuncio
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_baja_anuncio(p_anuncio INTEGER, p_motivo TEXT, p_usuario TEXT)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    UPDATE anuncios SET vigente = 'C', fecha_baja = NOW(), espubic = p_motivo WHERE anuncio = p_anuncio;
    v_result := json_build_object('anuncio', p_anuncio, 'status', 'baja');
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;