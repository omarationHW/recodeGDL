-- Stored Procedure: sp_edit_bloqueo_rfc
-- Tipo: CRUD
-- Descripción: Edita el motivo de un bloqueo vigente
-- Generado para formulario: bloqueoRFCfrm
-- Fecha: 2025-08-27 16:24:36

CREATE OR REPLACE FUNCTION sp_edit_bloqueo_rfc(
    p_rfc VARCHAR(13),
    p_observacion VARCHAR(255),
    p_capturista VARCHAR(10)
) RETURNS INTEGER AS $$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE bloqueo_rfc_lic SET observacion = p_observacion, hora = now(), capturista = p_capturista
    WHERE rfc = p_rfc AND vig = 'V';
    GET DIAGNOSTICS v_updated = ROW_COUNT;
    RETURN v_updated;
END;
$$ LANGUAGE plpgsql;